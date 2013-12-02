/* ============================================================

    Copyright (c) 2011 Advanced Micro Devices, Inc.  

============================================================ */

// OVEncode.h
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the OVENCODE_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// OVENCODE_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.

// Open Encode Change define Win32
#define _WIN32 1
// end Open Encode Note/Change

#ifndef __OVENCODE_H__
#define __OVENCODE_H__

#ifndef OPENVIDEOAPI
#define OPENVIDEOAPI __stdcall
#endif // OPENVIDEOAPI


#include "OVEncodeTypes.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

    int OPENVIDEOAPI fnOVEncode(void);

    /* 
     * This function is used by the application to query the available encoder devices. 
     * The ovencode_device_info contains a unique device_id and the size of the 
     * encode_cap structure for each available device. The encode_cap size is the
     * size of the encode_cap structure that the application should provide in
     * the OVEncodeGetDeviceCap call.
     */
    OVresult OPENVIDEOAPI OVEncodeGetDeviceInfo (
        unsigned int            *num_device,
        ovencode_device_info    *device_info);

    /*
     * This function is used by application to query the encoder capability that includes
     * codec information and format that the device can support.
     */
    OVresult OPENVIDEOAPI OVEncodeGetDeviceCap (
        OPContextHandle             platform_context,
        unsigned int                device_id,
        unsigned int                encode_cap_list_size,
        unsigned int                *num_encode_cap,
        OVE_ENCODE_CAPS             *encode_cap_list);

    /*
     * This function is used by the application to create the encode handle from the 
     * platform memory handle. The encode handle can be used in the OVEncodePicture 
     * function as the output encode buffer. The application can create multiple 
     * output buffers to queue up the decode job. 
     */
    ove_handle OPENVIDEOAPI OVCreateOVEHandleFromOPHandle (
        OPMemHandle                 platform_memhandle);

    /* 
     * This function is used by the application to release the encode handle. 
     * After release, the handle is invalid and should not be used for encode picture. 
     */
    OVresult OPENVIDEOAPI OVReleaseOVEHandle(
        ove_handle                  encode_handle);

    /* 
     * This function is used by the application to acquire the memory objects that 
     * have been created from OpenCL. These objects need to be acquired before they 
     * can be used by the decode function. 
     */

    OVresult OPENVIDEOAPI OVEncodeAcquireObject (
        ove_session                 session,
        unsigned int                num_handle,
        ove_handle                 *encode_handle,
        unsigned int                num_event_in_wait_list,
        OPEventHandle              *event_wait_list,
        OPEventHandle              *event);

    /*
     * This function is used by the application to release the memory objects that
     * have been created from OpenCL. The objects need to be released before they
     * can be used by OpenCL.
     */
    OVresult OPENVIDEOAPI OVEncodeReleaseObject (
       ove_session                  session,
       unsigned int                 num_handle,
       ove_handle                  *encode_handle,
       unsigned int                 num_event_in_wait_list,
       OPEventHandle               *event_wait_list,
       OPEventHandle               *event);


	ove_event OPENVIDEOAPI OVCreateOVEEventFromOPEventHandle (
        OPEventHandle               platform_eventhandle);

    /* 
     * This function is used by the application to release the encode event handle. 
     * After release, the event handle is invalid and should not be used. 
     */
    OVresult OPENVIDEOAPI OVEncodeReleaseOVEEventHandle (
        ove_event                   ove_ev);


    /*
     * This function is used by the application to create the encode session for
     * each encoding stream. After the session creation, the encoder is ready to
     * accept the encode picture job from the application. For multiple streams
     * encoding, the application can create multiple sessions within the same
     * platform context and the application is responsible to manage the input and
     * output buffers for each corresponding session.
     */
    ove_session OPENVIDEOAPI OVEncodeCreateSession (
        OPContextHandle             platform_context,
        unsigned int                device_id,
        OVE_ENCODE_MODE             encode_mode,
        OVE_PROFILE_LEVEL           encode_profile,
        OVE_PICTURE_FORMAT	        encode_format,
        unsigned int                encode_width,
        unsigned int                encode_height,
        OVE_ENCODE_TASK_PRIORITY    encode_task_priority);

    /*
     * This function is used by the application to destroy the encode session. Destroying a
     * session will release all associated hardware resources.  No further decoding work
     * can be performed with the session after it is destroyed.
     */
    OVresult OPENVIDEOAPI OVEncodeDestroySession (
        ove_session                 session);

	// Retrieve one configuration data structure
	OVresult OPENVIDEOAPI OVEncodeGetPictureControlConfig (
        ove_session                 session,
        OVE_CONFIG_PICTURE_CONTROL *pPictureControlConfig);

	// Get current rate control configuration
	OVresult OPENVIDEOAPI OVEncodeGetRateControlConfig (
        ove_session                 session,
        OVE_CONFIG_RATE_CONTROL	   *pRateControlConfig);

	// Get current motion estimation configuration
	OVresult OPENVIDEOAPI OVEncodeGetMotionEstimationConfig (
        ove_session                 session,
        OVE_CONFIG_MOTION_ESTIMATION *pMotionEstimationConfig);

	// Get current RDO configuration
	OVresult OPENVIDEOAPI OVEncodeGetRDOControlConfig (
        ove_session             session,
        OVE_CONFIG_RDO          *pRDOConfig);

	OVresult OPENVIDEOAPI OVEncodeSendConfig (
        ove_session             session,
        unsigned int            num_of_config_buffers,
        OVE_CONFIG              *pConfigBuffers);

	// Fully encode a single picture
	OVresult OPENVIDEOAPI OVEncodeTask (
        ove_session             session,
        unsigned int            number_of_encode_task_input_buffers,
        OVE_INPUT_DESCRIPTION   *encode_task_input_buffers_list,
        void                    *picture_parameter,
        unsigned int            *pTaskID,
        unsigned int            num_event_in_wait_list,
        ove_event               *event_wait_list,
        ove_event               *event);

	// Query outputs
	OVresult OPENVIDEOAPI OVEncodeQueryTaskDescription (
        ove_session             session,
        unsigned int            num_of_task_description_request,
        unsigned int            *num_of_task_description_return,
        OVE_OUTPUT_DESCRIPTION  *task_description_list);

	// Reclaim the resource of the output ring up to the specified task.
	OVresult OPENVIDEOAPI OVEncodeReleaseTask (
        ove_session             session,
        unsigned int            taskID);


#ifdef __cplusplus
};
#endif //  __cplusplus

#endif // __OVENCODE_H__