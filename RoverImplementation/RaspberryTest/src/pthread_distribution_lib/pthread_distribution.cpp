/*
 * Copyright (c) 2017 PIMES, Fachhochschule Dortmund
 *
 * Description:
 *    pThread Core Affinity Pinning
 *
 * Supervision:
 *    Robert Hottger
 *
 * Authors:
 *    Mustafa Ozcelikors <mozcelikors@gmail.com>   02.02.2017 - compilation
 *
 * Contributors:
 *
 */


#include "pthread_distribution.h"


int placeThisThreadToCore(int core_id)
{
   int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
   if (core_id < 0 || core_id >= num_cores)
      return EINVAL;

   cpu_set_t cpuset;
   CPU_ZERO(&cpuset);
   CPU_SET(core_id, &cpuset);

   pthread_t current_thread = pthread_self();
   int rc = pthread_setaffinity_np(current_thread, sizeof(cpu_set_t), &cpuset);
   if (rc != 0) {
         std::cerr << "Error calling pthread_setaffinity_np: " << rc << "\n";
   }
   return rc;
}


int placeAThreadToCore (pthread_t thread, int core_id)
{
   int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
   if (core_id < 0 || core_id >= num_cores)
      return EINVAL;

   cpu_set_t cpuset;
   CPU_ZERO(&cpuset);
   CPU_SET(core_id, &cpuset);

   int rc = pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);
   if (rc != 0) {
         std::cerr << "Error calling pthread_setaffinity_np: " << rc << "\n";
   }
   return rc;
}

