FIND_PATH(VERILATOR_ROOT_DIR bin/verilator)

IF (VERILATOR_ROOT_DIR)
    SET(Verilator_FOUND TRUE)
ENDIF (VERILATOR_ROOT_DIR)


IF (Verilator_FOUND)
    SET(VERILATOR_EXECUTABLE ${VERILATOR_ROOT_DIR}/bin/verilator)
    IF (NOT Verilato_FIND_QUIETLY)
        MESSAGE(STATUS "Found Verilator: ${VERILATOR_EXECUTABLE}")
    ENDIF (NOT Verilato_FIND_QUIETLY)
ELSE (Verilator_FOUND)
    IF (Verilator_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find Verilator!")
    ENDIF (Verilator_FIND_REQUIRED)
ENDIF (Verilator_FOUND)