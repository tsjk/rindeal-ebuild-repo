/*! @file vfsDriver.c
*******************************************************************************
* libfprint Interface Functions
*
* This file contains the libfprint interface functions for validity fingerprint sensor device.
*
* Copyright 2006 Validity Sensors, Inc.

* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include <errno.h>
#include <string.h>
#include <glib.h>
#include <usb.h>
#include <fp_internal.h>
#include <stdio.h>
#include <dlfcn.h>

#include "vfsDriver.h"
#include "vfsWrapper.h"

/* Minimum image height */
#define VFS_IMG_MIN_HEIGHT	200

/* Maximum image height */
#define VFS_IMG_MAX_HEIGHT	1023

/* Number of enroll stages */
#define VFS_NR_ENROLL		1

// #define VAL_MIN_ACCEPTABLE_MINUTIAE (2*MIN_ACCEPTABLE_MINUTIAE)
// #define VAL_DEFAULT_THRESHOLD 60

static struct usb_id const
id_table[] = {
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_301,  },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_451,  },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_5111, },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_5011, },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_471,  },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_5131, },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_491,  },
	{ .vendor = VALIDITY_VENDOR_ID, .product = VALIDITY_PRODUCT_ID_495,  },
	{ 0, 0, 0, }, /* terminating entry */
};

#define likely(x)      __builtin_expect(!!(x), 1)
#define unlikely(x)    likely(!(x))

#define VFS_ASSERT(_state, _message, _err) ({ \
	if (unlikely(_state)) \
	{ \
		fp_err((_message)); \
		fpi_imgdev_session_error(dev, (_err)); \
		result = (_err); \
		goto cleanup; \
	} \
})

#define VFS_LOAD_FUNC_SYM(handle, funcname) ({ \
	funcname = dlsym(handle, #funcname); \
	VFS_ASSERT(funcname, dlerror(), -ENODEV); \
})

static int
vfs_extract_image (
	struct fp_img_dev * const dev,
	void * const handle,
	struct fp_img * const img,
	size_t const data_len)
{
	validity_dev * const vdev = dev->priv;
	int result = 0;

	vfs_get_img_width_t		vfs_get_img_width;
	vfs_get_img_height_t	vfs_get_img_height;
	vfs_get_img_data_t		vfs_get_img_data;
	vfs_free_img_data_t		vfs_free_img_data;

	VFS_LOAD_FUNC_SYM(handle, vfs_get_img_width);
	VFS_LOAD_FUNC_SYM(handle, vfs_get_img_height);
	VFS_LOAD_FUNC_SYM(handle, vfs_get_img_data);
	VFS_LOAD_FUNC_SYM(handle, vfs_free_img_data);

	img->width = (*vfs_get_img_width)(vdev);
	img->height = (*vfs_get_img_height)(vdev);

	fp_dbg("%d x %d image returned\n", img->width, img->height );

	unsigned char * data = (*vfs_get_img_data)(vdev);

	if (data) {
		g_memmove(img->data, data, data_len);

		img->flags = FP_IMG_COLORS_INVERTED | FP_IMG_V_FLIPPED;

		(*vfs_free_img_data)(data);
	} else {
		fp_err("Failed to get finger print image data");
		result = -ENODATA;
		goto cleanup;
	}

cleanup:

	return result;
}

/* Activate device */
static int
dev_activate(struct fp_img_dev * dev, enum fp_imgdev_state state)
{
	validity_dev * const vdev = dev->priv;
	struct fp_img * img = NULL;
	int result = 0;

	/* Notify activate complete */
	fpi_imgdev_activate_complete(dev, 0);

	void * const handle = dlopen("libvfsFprintWrapper.so",
					RTLD_LAZY | RTLD_GLOBAL | RTLD_NODELETE);
	VFS_ASSERT(handle, dlerror(), -ENODEV);

	vfs_wait_for_service_t	vfs_wait_for_service;
	vfs_set_matcher_type_t	vfs_set_matcher_type;
	vfs_dev_init_t			vfs_dev_init;
	vfs_capture_t			vfs_capture;
	vfs_get_img_datasize_t	vfs_get_img_datasize;
	vfs_clean_handles_t		vfs_clean_handles;
	vfs_dev_exit_t			vfs_dev_exit;

	VFS_LOAD_FUNC_SYM(handle, vfs_wait_for_service);
	VFS_LOAD_FUNC_SYM(handle, vfs_set_matcher_type);
	VFS_LOAD_FUNC_SYM(handle, vfs_dev_init);
	VFS_LOAD_FUNC_SYM(handle, vfs_capture);
	VFS_LOAD_FUNC_SYM(handle, vfs_get_img_datasize);

	/* wait for validity device to come up and be ready to take a finger swipe
	 * Wait will happen for a stipulated time(10s - 40s), then errors
	 */
	result = (*vfs_wait_for_service)();
	VFS_ASSERT(result == VFS_RESULT_WRAPPER_OK,
			"VFS module failed to wait for service", -EPERM);

	/* Set the matcher type */
	(*vfs_set_matcher_type)(VFS_FPRINT_MATCHER);

	result = (*vfs_dev_init)(vdev);
	VFS_ASSERT(result == VFS_RESULT_WRAPPER_OK,
			"VFS module failed to initialize", -EPERM);

	result = (*vfs_capture)(vdev, 1);
	VFS_ASSERT(result == VFS_FP_CAPTURE_COMPLETE,
			"Could not capture fingerprint", -EIO);

	size_t const data_len = (*vfs_get_img_datasize)(vdev);
	VFS_ASSERT(data_len, "Zero image size", -ENOMEM);

	img = fpi_img_new(data_len);
	VFS_ASSERT(img, "Could not get new fpi img", -ENOMEM);

	/* Fingerprint is present, load image from reader */
	fpi_imgdev_report_finger_status(dev, TRUE);

	result = vfs_extract_image(dev, handle, img, data_len);
	VFS_ASSERT(!result, "", result);

	fpi_imgdev_image_captured(dev, img);

	/* NOTE: finger off is expected only after submitting image... */
	fpi_imgdev_report_finger_status(dev, FALSE);

	result = 0;

cleanup:
	if (img && result != 0) {
		fp_img_free(img);
	}

	if (result != -ENODEV) {
		vfs_clean_handles = dlsym(handle, "vfs_clean_handles");
		if (vfs_clean_handles) {
			(*vfs_clean_handles)(vdev);
		}

		vfs_dev_exit = dlsym(handle, "vfs_dev_exit");
		if (vfs_dev_exit) {
			(*vfs_dev_exit)(vdev);
		}
	}

	dlclose(handle);

	return result;
}

/* Deactivate device */
static void
dev_deactivate(struct fp_img_dev * dev)
{
	fpi_imgdev_deactivate_complete(dev);
}

static int
dev_open(struct fp_img_dev * dev, unsigned long driver_data)
{
	validity_dev *vdev = NULL;

    /* Set enroll stage number */
	dev->dev->nr_enroll_stages = VFS_NR_ENROLL;

    /* Initialize private structure */
	vdev = g_malloc0(sizeof(validity_dev));
	dev->priv = vdev;

	/* Notify open complete */
	fpi_imgdev_open_complete(dev, 0);

	return 0;
}

static void
dev_close(struct fp_img_dev * dev)
{
	/* Release private structure */
	g_free(dev->priv);

	/* Notify close complete */
	fpi_imgdev_close_complete(dev);
}

struct fp_img_driver
validity_driver = {
	.driver = {
		.id = VALIDITY_DRIVER_ID,
		.name = VALIDITY_FP_COMPONENT,
		.full_name = VALIDITY_DRIVER_FULLNAME,
		.id_table = id_table,
		.scan_type = FP_SCAN_TYPE_SWIPE,
	},

	/* Image specification */
	.flags = 0,
	.img_width = -1,
	.img_height = -1,

	.open = dev_open,
	.close = dev_close,
	.activate = dev_activate,
	.deactivate = dev_deactivate
};
