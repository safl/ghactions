cmake_minimum_required(VERSION 3.9)
set(EXAMPLES true CACHE BOOL "examples: include example programs in build")
if(NOT EXAMPLES)
	return()
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DXNVME_DEBUG_ENABLED")

include_directories("${PROJECT_SOURCE_DIR}/include")
message(STATUS "EXAMPLES-CMAKE_C_FLAGS(${CMAKE_C_FLAGS})")

file(GLOB SOURCE_FILES_EXAMPLES  ${CMAKE_CURRENT_SOURCE_DIR}/*.c)

foreach(SRC_FN ${SOURCE_FILES_EXAMPLES})
	get_filename_component(SRC_FN_WE ${SRC_FN} NAME_WE)

	set(EXE_NAME "${SRC_FN_WE}-EXAMPLES")
	set(EXE_FN "${PROJECT_NAME}_${SRC_FN_WE}")

	add_executable(${EXE_NAME} ${SRC_FN})
	set_target_properties(${EXE_NAME} PROPERTIES
		INTERPROCEDURAL_OPTIMIZATION HAS_IPO
		OUTPUT_NAME ${EXE_FN}
	)

	target_include_directories(${EXE_NAME}
		PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

	target_compile_options(${EXE_NAME} PUBLIC -MMD)
	target_compile_options(${EXE_NAME} PUBLIC -MP)
	target_compile_options(${EXE_NAME} PUBLIC -MF)
	target_compile_options(${EXE_NAME} PUBLIC -fPIE)

	target_link_libraries(${EXE_NAME} ${LIBS_SYSTEM} ${LIB_STATIC})

	install(TARGETS ${EXE_NAME} DESTINATION bin COMPONENT examples)

	set(COMPLETION_SCRIPT
		${PROJECT_SOURCE_DIR}/scripts/bash_completion.d/${EXE_FN}-completions)

	# TODO: improve determination of DESTINATION
	if(DEFINED BASH_COMPLETION_COMPLETIONSDIR AND EXISTS ${COMPLETION_SCRIPT})
		install(FILES ${COMPLETION_SCRIPT}
			DESTINATION share/bash-completion/completions/
			RENAME ${EXE_FN}
			COMPONENT examples)
	endif()

	file(GLOB MAN_PAGES ${PROJECT_SOURCE_DIR}/man/${EXE_FN}-*.1)
	list(APPEND MAN_PAGES ${PROJECT_SOURCE_DIR}/man/${EXE_FN}.1)
	foreach(MAN_PAGE ${MAN_PAGES})
		if(EXISTS ${MAN_PAGE})
			install(FILES ${MAN_PAGE}
				DESTINATION share/man/man1
				COMPONENT examples)
		endif()
	endforeach()
endforeach()
