xCORE-200 explorer - Simple GPIO
================================

.. version:: 1.0.1

Summary
-------

This application note show how to use simple GPIO on an xCORE-200 explorer
development kit. The kit itself contains buttons and LED's which can be
accessed from application code running on the xCORE multicore microcontroller.

The example uses the XMOS GPIO library to demonstrate how simple GPIO devices
can be accessed from multibit ports in an easy and efficient manner. It also 
demonstrates how to respond to events from within application code.

The code in the example builds a simple GPIO handling application which responds to
button presses from the user and toggles the state of LED's on the development
board.

Required tools and libraries
............................

* xTIMEcomposer Tools - Version 14.0 
* XMOS GPIO library - Version 1.0.0

Required hardware
.................

This application note is designed to run on any XMOS multicore microcontroller.

The example code provided with the application has been implemented and tested
on the xCORE-200 explorer kit. The dependancy on this board is only due to the
GPIO ports that are connected to the buttons and LED's. These port definitions are
in the source code and can be easily modified to work on another XMOS development
board.

Prerequisites
.............

  - This document assumes familiarity with the XMOS xCORE architecture, the XMOS GPIO library, 
    the XMOS tool chain and the xC language. Documentation related to these aspects which are 
    not specific to this application note are linked to in the references appendix.

  - For descriptions of XMOS related terms found in this document please see the XMOS Glossary [#]_.

  - For the information relating to the GPIO library, please see the document XMOS GPIO Library [#]_.

  .. [#] http://www.xmos.com/published/glossary

  .. [#] http://www.xmos.com/published/xmos-gpio-lib

