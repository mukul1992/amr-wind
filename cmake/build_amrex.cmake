function(build_amrex_library AMREX_DIM AMREX_ENABLE_EB)
  # Set library suffixes for EB enabled
  if(AMREX_ENABLE_EB)
    set(EB "eb")
  else()
    unset(EB)
  endif()

  #Expose functions we want to be able to call
  include(${CMAKE_SOURCE_DIR}/cmake/add_source_function.cmake)
  include(${CMAKE_SOURCE_DIR}/cmake/amrex_sources.cmake)

  #Clear source file list from any previous executables
  set_property(GLOBAL PROPERTY GlobalSourceList "")

  #Aggregate amrex and pelephysics source files
  get_amrex_sources()

  #Put source list from global property into local list
  get_property(AMREX_SOURCES GLOBAL PROPERTY GlobalSourceList)

  #Create an executable based on all the source files we aggregated
  add_library(amrex${AMREX_DIM}d${EB} ${AMREX_SOURCES})

  #AMReX definitions
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE BL_SPACEDIM=${AMREX_DIM})
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE BL_FORT_USE_UNDERSCORE)
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE AMREX_SPACEDIM=${AMREX_DIM})
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE AMREX_FORT_USE_UNDERSCORE)
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:BL_LANG_FORT>)
  target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE $<$<COMPILE_LANGUAGE:Fortran>:AMREX_LANG_FORT>)

  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE BL_Darwin)
    target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE AMREX_Darwin)
  endif()

  #AMR-Wind definitions
  if(AMREX_ENABLE_EB)
    target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE AMREX_USE_EB)
  endif()

  #AMReX include directories
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/Base)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/AmrCore)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/Boundary)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/LinearSolvers/MLMG)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/LinearSolvers/Projections)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Tools/C_scripts)
  target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_BINARY_DIR}/fortran_modules/amrex${AMREX_DIM}d${EB}_fortran_modules)
  if(AMREX_ENABLE_EB)
    target_include_directories(amrex${AMREX_DIM}d${EB} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/submods/amrex/Src/EB)
  endif()

  #Link our executable to the MPI libraries, etc
  if(AMR_WIND_ENABLE_MPI)
    target_link_libraries(amrex${AMREX_DIM}d${EB} PRIVATE MPI::MPI_CXX MPI::MPI_Fortran)
    target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE BL_USE_MPI)
    target_compile_definitions(amrex${AMREX_DIM}d${EB} PRIVATE AMREX_USE_MPI)
  endif()

  #Needed for Travis CI system for some reason
  target_link_libraries(amrex${AMREX_DIM}d${EB} PRIVATE Threads::Threads)

  #Keep our Fortran module files confined to a unique directory for each executable 
  set_target_properties(amrex${AMREX_DIM}d${EB} PROPERTIES Fortran_MODULE_DIRECTORY
                       "${CMAKE_BINARY_DIR}/fortran_modules/amrex${AMREX_DIM}d${EB}_fortran_modules")

  #Define what we want to be installed during a make install 
  install(TARGETS amrex${AMREX_DIM}d${EB}
          RUNTIME DESTINATION bin
          ARCHIVE DESTINATION lib
          LIBRARY DESTINATION lib)
endfunction(build_amrex_library AMREX_DIM AMREX_ENABLE_EB)

function(build_amrex)
   set(AMREX_ENABLE_EB ${AMR_WIND_ENABLE_EB})
   set(AMREX_DIM ${AMR_WIND_DIM})
   build_amrex_library(${AMREX_DIM} ${AMREX_ENABLE_EB})
endfunction(build_amrex)