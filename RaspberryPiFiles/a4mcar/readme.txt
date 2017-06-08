Description:
	A4MCAR Project - Readme File

Author:
	M. Ozcelikors <mozcelikors@gmail.com>, Fachhochschule Dortmund

Supervision & Mentoring:
	Robert Hoettger 

Disclaimer:
	Copyright (c) 2017 FH Dortmund and others
	All rights reserved. This program and the accompanying materials are made available under the
	terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at
	http://www.eclipse.org/legal/epl-v10.html
	
	This project has been granted during the Google Summer of Code 2017.

Scope:
	In this readme file, the project descriptions and objectives are given. This readme file also 
	introduces the file system of all the applications developed for XMOS xCORE-200 eXplorerKIT, 
	Raspberry Pi 3, and Android phones, as well its shows where created models and scripts are 
	located. 
	
Project Abstract:
	Distributing software effectively to multi core, many core, and distributed systems has been 
	studied for decades but still advances successively driven by domain specific constraints. 
	Programming vehicle ECUs is one of the most constrained domains that recently approached the need
	for concurrency due to advanced driver assistant systems or autonomous driving approaches. 
	To answer the needs of automotive industry in this manner with an open-source approach, recent 
	studies have been made such as the Eclipse-based APP4MC platform. Although APP4MC provides 
	sufficient tooling in parallel computing for automotive domain, the demonstration and evaluation 
	of its results would improve its performance and allow to investigate the optimization of goals 
	such as resource usage and energy consumption. With the project, software distribution challenges
	for such automotive systems should be analyzed upon instruction precise modeling, affinity
	constrained distribution, and reducing task response times achieved by advanced software 
	parallelization. Advanced software parallelization will be achieved on a remote controlled
	demonstrator car that will have a distributed and parallel architecture.

	A4MCAR is a demonstrator car which features not only low level functionalities such
	as sensor and motor driving but also high level features such as image processing,
	camera streaming, server-based wireless driving via Web, bluetooth connectivity 
	via Android application, system core monitoring and analysis features and touchscreen UI.
	Our experiments along the multi-task heterogeneous demonstrator A4MCAR show that using APP4MC 
	results instead of OS-based or sequential implementations on a distributed heterogeneous 
	system significantly improves its responsiveness in order to potentially reduce energy
	consumption and replaces error prone manual constraint considerations for mixed-critical
	applications.  
	
Project Objectives:
	- Development of a distributed multi-core demonstrator for the APP4MC platform that involves
	features with the emphasis of automotive applications.
	- General study on parallelization, scheduling, and popular trends (such as POSIX threads,
	RTOS paralellization etc.)
	- Researching techniques to retrieve information (number of instructions, communication costs)
	and system trace from platforms such as xCORE and Linux to achieve precise modelling with APP4MC.
	- In order to achieve optimization goals such as reduced energy consumption and reduced resource
	usage, different affinity constrained software distributions will be evaluated and energy features
	will be invoked to see if the goals are met.
	- Developing a basic and modular online parallelization evaluation software that will retrieve 
	scheduling properties such as slack times, execution times, and deadlines from all the processes
	and that will tell how many of the deadlines are met, how good of a software distribution it is
	while the software is being executed.
	- Also taking system traces from the software to carry out offline software evaluation in order
	to figure out means to balance the load on cores.
	- Comparing the conventional schedulers non-constrained affinity distribution (such as a Linux OS
	scheduler) to the affinity constrained distribution from APP4MC to see if performance can be 
	improved.
	
File System and Applications:
	The a4mcar directory have to be placed in the home directory: /home/pi
	The external libraries and modules that needs to be downloaded are located at: 
		https://gitlab.pimes.fh-dortmund.de/RPublic/a4mcar_required_modules.git
		
		The dependencies are installed using setup scripts that are created. External modules involve 
		virtkeyboard, psutil, mjpg_streamer for those who want to manually install the dependencies.
		
	The repository should have the following main folders:
	
	web_interface :				The web interface that is developed for A4MCAR project which is used to control 
								A4MCAR over remote Wi-Fi connection. 
								
								In order to set up web_interface, run the setup script:
								web_interface/setup_web_interface.sh
										
								In order to run the web_interface correctly, the high-level modules core_reader
								and ethernet_client should be ready and working.
								To run the web_interface one should connect to the access point of Raspberry Pi
								from a client computer web browser and visit 
								http://<IP_Address>/jqueryControl2.php or http://<IP_Address>/jqueryControl.php
					
	high_level_applications :	This module consists of several high-level applications that are developed for
								A4MCAR's high-level module (Raspberry Pi). These applications involve: 
								touchscreen_display, core_recorder, dummy_loads, ethernet_client, and 
								image_processing.
								
								In order to run the applications, respective Python files could be run or C/C++
								binaries could be executed. Also the scripts that are located under scripts 
								folder could be used to initialize some of the applications.
								
								In order to set up high_level_applications module dependencies, one should run
								the setup script and follow the instructions:
								high_level_applications/setup_high_level_applications.sh
									
	models:						A4MCAR's hardware and software model with Eclipse APP4MC is located in this 
								directory.
								
	android_application:		This directory consists of the source files that belong to the A4MCAR's bluetooth
								based driving application. The source and design files could be used in an Android
								IDE in order to make tweaks to the application and to generate new .apk files.
								
	low_level_applications:		low_level_applications module involves the source code for the low-level module that
								are run using a multi-core microcontroller XMOS xCORE-200 eXplorerKIT. The low level
								applications are responsible for tasks such as sensor driving, actuation, communication,
								and core monitoring of the A4MCAR. The low_level_applications module could be imported
								into xTIMEcomposer to make tweaks to the tasks.
					