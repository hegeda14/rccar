
#include <stdlib.h>
#include <string.h>
#include "sc_types.h"
#include "RC_CAR.h"
/*! \file Implementation of the state machine 'RC-CAR'
*/

// prototypes of all internal functions

static void rC_CAR_entryaction(RC_CAR* handle);
static void rC_CAR_exitaction(RC_CAR* handle);
static void rC_CAR_react_main_region_Idle(RC_CAR* handle);
static void rC_CAR_react_main_region_Abstand_halten_r1_vor(RC_CAR* handle);
static void rC_CAR_react_main_region_Abstand_halten_r1_zurueck(RC_CAR* handle);
static void rC_CAR_react_main_region_Abstand_halten_r1_stehen(RC_CAR* handle);
static void clearInEvents(RC_CAR* handle);
static void clearOutEvents(RC_CAR* handle);


void rC_CAR_init(RC_CAR* handle)
{
	int i;

	for (i = 0; i < RC_CAR_MAX_ORTHOGONAL_STATES; ++i)
		handle->stateConfVector[i] = RC_CAR_last_state;
	
	
	handle->stateConfVectorPosition = 0;

clearInEvents(handle);
clearOutEvents(handle);

	// TODO: initialize all events ...

	{
		/* Default init sequence for statechart RC-CAR */
		handle->iface.speed = 0;
		handle->iface.control = 0;
		handle->iface.distance = 0;
	}

}

void rC_CAR_enter(RC_CAR* handle)
{
	{
		/* Default enter sequence for statechart RC-CAR */
		rC_CAR_entryaction(handle);
		{
			/* 'default' enter sequence for region main region */
			{
				/* Default react sequence for initial entry  */
				{
					/* 'default' enter sequence for state Idle */
					handle->stateConfVector[0] = RC_CAR_main_region_Idle;
					handle->stateConfVectorPosition = 0;
				}
			}
		}
	}
}

void rC_CAR_exit(RC_CAR* handle)
{
	{
		/* Default exit sequence for statechart RC-CAR */
		{
			/* Default exit sequence for region main region */
			/* Handle exit of all possible states (of main region) at position 0... */
			switch(handle->stateConfVector[ 0 ]) {
				case RC_CAR_main_region_Idle : {
					{
						/* Default exit sequence for state Idle */
						handle->stateConfVector[0] = RC_CAR_last_state;
						handle->stateConfVectorPosition = 0;
					}
					break;
				}
				case RC_CAR_main_region_Abstand_halten_r1_vor : {
					{
						/* Default exit sequence for state vor */
						handle->stateConfVector[0] = RC_CAR_last_state;
						handle->stateConfVectorPosition = 0;
					}
					break;
				}
				case RC_CAR_main_region_Abstand_halten_r1_zurueck : {
					{
						/* Default exit sequence for state zurueck */
						handle->stateConfVector[0] = RC_CAR_last_state;
						handle->stateConfVectorPosition = 0;
					}
					break;
				}
				case RC_CAR_main_region_Abstand_halten_r1_stehen : {
					{
						/* Default exit sequence for state stehen */
						handle->stateConfVector[0] = RC_CAR_last_state;
						handle->stateConfVectorPosition = 0;
					}
					break;
				}
				default: break;
			}
		}
		rC_CAR_exitaction(handle);
	}
}

static void clearInEvents(RC_CAR* handle) {
	handle->iface.button_1_raised = bool_false;
}

static void clearOutEvents(RC_CAR* handle) {
}

void rC_CAR_runCycle(RC_CAR* handle) {
	
	clearOutEvents(handle);
	
	for (handle->stateConfVectorPosition = 0;
		handle->stateConfVectorPosition < RC_CAR_MAX_ORTHOGONAL_STATES;
		handle->stateConfVectorPosition++) {
			
		switch (handle->stateConfVector[handle->stateConfVectorPosition]) {
		case RC_CAR_main_region_Idle : {
			rC_CAR_react_main_region_Idle(handle);
			break;
		}
		case RC_CAR_main_region_Abstand_halten_r1_vor : {
			rC_CAR_react_main_region_Abstand_halten_r1_vor(handle);
			break;
		}
		case RC_CAR_main_region_Abstand_halten_r1_zurueck : {
			rC_CAR_react_main_region_Abstand_halten_r1_zurueck(handle);
			break;
		}
		case RC_CAR_main_region_Abstand_halten_r1_stehen : {
			rC_CAR_react_main_region_Abstand_halten_r1_stehen(handle);
			break;
		}
		default:
			break;
		}
	}
	
	clearInEvents(handle);
}


sc_boolean rC_CAR_isActive(RC_CAR* handle, RC_CARStates state) {
	switch (state) {
		case RC_CAR_main_region_Idle : 
			return (sc_boolean) (handle->stateConfVector[0] == RC_CAR_main_region_Idle
			);
		case RC_CAR_main_region_Abstand_halten : 
			return (sc_boolean) (handle->stateConfVector[0] >= RC_CAR_main_region_Abstand_halten
				&& handle->stateConfVector[0] <= RC_CAR_main_region_Abstand_halten_r1_stehen);
		case RC_CAR_main_region_Abstand_halten_r1_vor : 
			return (sc_boolean) (handle->stateConfVector[0] == RC_CAR_main_region_Abstand_halten_r1_vor
			);
		case RC_CAR_main_region_Abstand_halten_r1_zurueck : 
			return (sc_boolean) (handle->stateConfVector[0] == RC_CAR_main_region_Abstand_halten_r1_zurueck
			);
		case RC_CAR_main_region_Abstand_halten_r1_stehen : 
			return (sc_boolean) (handle->stateConfVector[0] == RC_CAR_main_region_Abstand_halten_r1_stehen
			);
		default: return bool_false;
	}
}

void rC_CARIface_raise_button_1(RC_CAR* handle) {
	handle->iface.button_1_raised = bool_true;
}


sc_integer rC_CARIface_get_speed(RC_CAR* handle) {
	return handle->iface.speed;
}
void rC_CARIface_set_speed(RC_CAR* handle, sc_integer value) {
	handle->iface.speed = value;
}
sc_integer rC_CARIface_get_control(RC_CAR* handle) {
	return handle->iface.control;
}
void rC_CARIface_set_control(RC_CAR* handle, sc_integer value) {
	handle->iface.control = value;
}
sc_integer rC_CARIface_get_distance(RC_CAR* handle) {
	return handle->iface.distance;
}
void rC_CARIface_set_distance(RC_CAR* handle, sc_integer value) {
	handle->iface.distance = value;
}
		
// implementations of all internal functions

/* Entry action for statechart 'RC-CAR'. */
static void rC_CAR_entryaction(RC_CAR* handle) {
	{
		/* Entry action for statechart 'RC-CAR'. */
	}
}

/* Exit action for state 'RC-CAR'. */
static void rC_CAR_exitaction(RC_CAR* handle) {
	{
		/* Exit action for state 'RC-CAR'. */
	}
}

/* The reactions of state Idle. */
static void rC_CAR_react_main_region_Idle(RC_CAR* handle) {
	{
		/* The reactions of state Idle. */
		if (handle->iface.button_1_raised) { 
			{
				/* Default exit sequence for state Idle */
				handle->stateConfVector[0] = RC_CAR_last_state;
				handle->stateConfVectorPosition = 0;
			}
			{
				/* 'default' enter sequence for state Abstand halten */
				{
					/* 'default' enter sequence for region r1 */
					{
						/* Default react sequence for initial entry  */
						{
							/* 'default' enter sequence for state stehen */
							{
								/* Entry action for state 'stehen'. */
								handle->iface.speed = 150000;
							}
							handle->stateConfVector[0] = RC_CAR_main_region_Abstand_halten_r1_stehen;
							handle->stateConfVectorPosition = 0;
						}
					}
				}
			}
		} 
	}
}

/* The reactions of state vor. */
static void rC_CAR_react_main_region_Abstand_halten_r1_vor(RC_CAR* handle) {
	{
		/* The reactions of state vor. */
		if (handle->iface.button_1_raised) { 
			{
				/* Default exit sequence for state Abstand halten */
				{
					/* Default exit sequence for region r1 */
					/* Handle exit of all possible states (of r1) at position 0... */
					switch(handle->stateConfVector[ 0 ]) {
						case RC_CAR_main_region_Abstand_halten_r1_vor : {
							{
								/* Default exit sequence for state vor */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_zurueck : {
							{
								/* Default exit sequence for state zurueck */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_stehen : {
							{
								/* Default exit sequence for state stehen */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						default: break;
					}
				}
			}
			{
				/* 'default' enter sequence for state Idle */
				handle->stateConfVector[0] = RC_CAR_main_region_Idle;
				handle->stateConfVectorPosition = 0;
			}
		}  else {
			if (handle->iface.distance < 40) { 
				{
					/* Default exit sequence for state vor */
					handle->stateConfVector[0] = RC_CAR_last_state;
					handle->stateConfVectorPosition = 0;
				}
				{
					/* 'default' enter sequence for state stehen */
					{
						/* Entry action for state 'stehen'. */
						handle->iface.speed = 150000;
					}
					handle->stateConfVector[0] = RC_CAR_main_region_Abstand_halten_r1_stehen;
					handle->stateConfVectorPosition = 0;
				}
			} 
		}
	}
}

/* The reactions of state zurueck. */
static void rC_CAR_react_main_region_Abstand_halten_r1_zurueck(RC_CAR* handle) {
	{
		/* The reactions of state zurueck. */
		if (handle->iface.button_1_raised) { 
			{
				/* Default exit sequence for state Abstand halten */
				{
					/* Default exit sequence for region r1 */
					/* Handle exit of all possible states (of r1) at position 0... */
					switch(handle->stateConfVector[ 0 ]) {
						case RC_CAR_main_region_Abstand_halten_r1_vor : {
							{
								/* Default exit sequence for state vor */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_zurueck : {
							{
								/* Default exit sequence for state zurueck */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_stehen : {
							{
								/* Default exit sequence for state stehen */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						default: break;
					}
				}
			}
			{
				/* 'default' enter sequence for state Idle */
				handle->stateConfVector[0] = RC_CAR_main_region_Idle;
				handle->stateConfVectorPosition = 0;
			}
		}  else {
			if (handle->iface.distance > 30) { 
				{
					/* Default exit sequence for state zurueck */
					handle->stateConfVector[0] = RC_CAR_last_state;
					handle->stateConfVectorPosition = 0;
				}
				{
					/* 'default' enter sequence for state stehen */
					{
						/* Entry action for state 'stehen'. */
						handle->iface.speed = 150000;
					}
					handle->stateConfVector[0] = RC_CAR_main_region_Abstand_halten_r1_stehen;
					handle->stateConfVectorPosition = 0;
				}
			} 
		}
	}
}

/* The reactions of state stehen. */
static void rC_CAR_react_main_region_Abstand_halten_r1_stehen(RC_CAR* handle) {
	{
		/* The reactions of state stehen. */
		if (handle->iface.button_1_raised) { 
			{
				/* Default exit sequence for state Abstand halten */
				{
					/* Default exit sequence for region r1 */
					/* Handle exit of all possible states (of r1) at position 0... */
					switch(handle->stateConfVector[ 0 ]) {
						case RC_CAR_main_region_Abstand_halten_r1_vor : {
							{
								/* Default exit sequence for state vor */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_zurueck : {
							{
								/* Default exit sequence for state zurueck */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						case RC_CAR_main_region_Abstand_halten_r1_stehen : {
							{
								/* Default exit sequence for state stehen */
								handle->stateConfVector[0] = RC_CAR_last_state;
								handle->stateConfVectorPosition = 0;
							}
							break;
						}
						default: break;
					}
				}
			}
			{
				/* 'default' enter sequence for state Idle */
				handle->stateConfVector[0] = RC_CAR_main_region_Idle;
				handle->stateConfVectorPosition = 0;
			}
		}  else {
			if (handle->iface.distance > 40) { 
				{
					/* Default exit sequence for state stehen */
					handle->stateConfVector[0] = RC_CAR_last_state;
					handle->stateConfVectorPosition = 0;
				}
				{
					/* 'default' enter sequence for state vor */
					{
						/* Entry action for state 'vor'. */
						handle->iface.speed = 140000;
					}
					handle->stateConfVector[0] = RC_CAR_main_region_Abstand_halten_r1_vor;
					handle->stateConfVectorPosition = 0;
				}
			}  else {
				if (handle->iface.distance < 20) { 
					{
						/* Default exit sequence for state stehen */
						handle->stateConfVector[0] = RC_CAR_last_state;
						handle->stateConfVectorPosition = 0;
					}
					{
						/* 'default' enter sequence for state zurueck */
						{
							/* Entry action for state 'zurueck'. */
							handle->iface.speed = 160000;
						}
						handle->stateConfVector[0] = RC_CAR_main_region_Abstand_halten_r1_zurueck;
						handle->stateConfVectorPosition = 0;
					}
				} 
			}
		}
	}
}


