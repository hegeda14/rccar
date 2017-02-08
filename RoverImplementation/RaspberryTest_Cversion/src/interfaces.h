
#ifndef INTERFACES_H_
#define INTERFACES_H_


extern float temperature_shared;
extern pthread_mutex_t temperature_lock;

extern float humidity_shared;
extern pthread_mutex_t humidity_lock;

extern int distance_shared;
extern pthread_mutex_t distance_lock;

extern char keycommand_shared;
extern pthread_mutex_t keycommand_lock;

extern float infrared_shared[2];
extern pthread_mutex_t infrared_lock;


#endif /* INTERFACES_H_ */
