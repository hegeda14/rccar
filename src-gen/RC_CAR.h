
#ifndef RC_CAR_H_
#define RC_CAR_H_

#include "sc_types.h"

#ifdef __cplusplus
extern "C" { 
#endif 

/*! \file Header of the state machine 'RC-CAR'.
*/

//! enumeration of all states 
typedef enum {
	RC_CAR_main_region_Idle ,
	RC_CAR_main_region_Abstand_halten ,
	RC_CAR_main_region_Abstand_halten_r1_vor ,
	RC_CAR_main_region_Abstand_halten_r1_zurueck ,
	RC_CAR_main_region_Abstand_halten_r1_stehen ,
	RC_CAR_last_state
} RC_CARStates;

//! Type definition of the data structure for the RC_CARIface interface scope.
typedef struct {
	sc_boolean button_1_raised;
	sc_integer speed;
	sc_integer control;
	sc_integer distance;
} RC_CARIface;


//! the maximum number of orthogonal states defines the dimension of the state configuration vector.
#define RC_CAR_MAX_ORTHOGONAL_STATES 1

/*! Type definition of the data structure for the RC_CAR state machine.
This data structure has to be allocated by the client code. */
typedef struct {
	RC_CARStates stateConfVector[RC_CAR_MAX_ORTHOGONAL_STATES];
	sc_ushort stateConfVectorPosition; 
	
	RC_CARIface iface;
} RC_CAR;

/*! Initializes the RC_CAR state machine data structures. Must be called before first usage.*/
extern void rC_CAR_init(RC_CAR* handle);

/*! Activates the state machine */
extern void rC_CAR_enter(RC_CAR* handle);

/*! Deactivates the state machine */
extern void rC_CAR_exit(RC_CAR* handle);

/*! Performs a 'run to completion' step. */
extern void rC_CAR_runCycle(RC_CAR* handle);


/*! Raises the in event 'button_1' that is defined in the default interface scope. */ 
extern void rC_CARIface_raise_button_1(RC_CAR* handle);

/*! Gets the value of the variable 'speed' that is defined in the default interface scope. */ 
extern sc_integer rC_CARIface_get_speed(RC_CAR* handle);
/*! Sets the value of the variable 'speed' that is defined in the default interface scope. */ 
extern void rC_CARIface_set_speed(RC_CAR* handle, sc_integer value);
/*! Gets the value of the variable 'control' that is defined in the default interface scope. */ 
extern sc_integer rC_CARIface_get_control(RC_CAR* handle);
/*! Sets the value of the variable 'control' that is defined in the default interface scope. */ 
extern void rC_CARIface_set_control(RC_CAR* handle, sc_integer value);
/*! Gets the value of the variable 'distance' that is defined in the default interface scope. */ 
extern sc_integer rC_CARIface_get_distance(RC_CAR* handle);
/*! Sets the value of the variable 'distance' that is defined in the default interface scope. */ 
extern void rC_CARIface_set_distance(RC_CAR* handle, sc_integer value);


/*! Checks if the specified state is active. */
extern sc_boolean rC_CAR_isActive(RC_CAR* handle, RC_CARStates state);

#ifdef __cplusplus
}
#endif 

#endif /* RC_CAR_H_ */
