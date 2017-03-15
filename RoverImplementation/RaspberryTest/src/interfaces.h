/*
 * Copyright (c) 2017 Eclipse Foundation, FH Dortmund and others
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Description:
 *    Interface file for shared resources
 *
 * Authors:
 *    M. Ozcelikors,            R.Hottger
 *    <mozcelikors@gmail.com>   <robert.hoettger@fh-dortmund.de>
 *
 * Contributors:
 *
 * Update History:
 *    02.02.2017   -    first compilation
 *    15.03.2017   -    updated tasks for web-based driving
 *
 */

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
