########################################################
# Author: Yuwen Xiong, Jamie Zhu <jimzhu@GitHub>
# License: MIT
# Last updated: 2016/5/11
########################################################

import time
import numpy as np
cimport numpy as np # import C-API
from libcpp cimport bool


#########################################################
# Make declarations on functions from cpp file
#
cdef extern from "c_WSPred.h":
    void WSPred(double *removedData, double *predData, int numUser, int numService, 
		int numTimeSlice, int dim, double etaInit, double lmda, double alpha, 
		int maxIter, bool debugMode, double *Udata, double *Sdata, double *Tdata)
#########################################################


#########################################################
# Function to perform the prediction algorithm
# Wrap up the C++ implementation
#
def predict(removedTensor, para):                         
    cdef int numService = removedTensor.shape[1] 
    cdef int numUser = removedTensor.shape[0]
    cdef int numTimeSlice = removedTensor.shape[2]
    cdef int dim = para['dimension']
    cdef double etaInit = para['etaInit']
    cdef double lmda = para['lambda']
    cdef double alpha = para['alpha']
    cdef int maxIter = para['maxIter']
    cdef bool debugMode = para['debugMode']

    # initialization
    cdef np.ndarray[double, ndim=2, mode='c'] U = np.random.rand(dim, numUser)        
    cdef np.ndarray[double, ndim=2, mode='c'] S = np.random.rand(dim, numService)
    cdef np.ndarray[double, ndim=2, mode='c'] T = np.random.rand(dim, numTimeSlice)
    cdef np.ndarray[double, ndim=3, mode='c'] predTensor =\
        np.zeros((numUser, numService, numTimeSlice))
        
    # Wrap up c_WSPred.cpp
    WSPred(
        <double *> (<np.ndarray[double, ndim=3, mode='c']> removedTensor).data,
        <double *> predTensor.data,
        numUser,
        numService,
        numTimeSlice,
        dim,
        etaInit,
        lmda,
        alpha,
        maxIter,
        debugMode,
        <double *> U.data,
        <double *> S.data,
        <double *> T.data
    )

    return predTensor
#########################################################
