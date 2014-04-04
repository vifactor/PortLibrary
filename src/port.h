/*
 * port.h
 *
 *  Created on: 13 july 2012
 *  Created on: 14 may 2013
 *      Author: kopp
 */

#ifndef PORT_H_
#define PORT_H_

extern "C" int divset_(int * alg, int * iv, int * liv, int * lv, double * v);
//  ***  SUPPLY ***SOL DEFAULT VALUES TO iv AND v  ***
//
//  ***  alg = 1 MEANS REGRESSION CONSTANTS.
//  ***  alg = 2 MEANS GENERAL UNCONSTRAINED OPTIMIZATION CONSTANTS.

extern "C" int n2fb_(int * n, int * p, float * x, float * xb,
		int (* NormFunc)(int * m, int * n, float * x, int * nf, float * v,int * ui, float * ur, int (* uf)()),
		int * iv, int * liv, int * lv, float * v, int * ui, float * ur, int (* uf) ());
//	***	 SINGLE PRECISION VERSION
//  ***  MINIMIZE A NONLINEAR SUM OF SQUARES USING RESIDUAL VALUES ONLY..
//  ***  THIS AMOUNTS TO DN2G WITHOUT THE SUBROUTINE PARAMETER CALCJ.

extern "C" int dn2fb_(int * n, int * p, double * x, double * xb,
		int (* NormFunc)(int * m, int * n, double * x, int * nf, double * v,int * ui, double * ur, int (* uf)()),
		int * iv, int * liv, int * lv, double * v, int * ui, double * ur, int (* uf) ());
//	***	 DOUBLE PRECISION VERSION
//  ***  MINIMIZE A NONLINEAR SUM OF SQUARES USING RESIDUAL VALUES ONLY..
//  ***  THIS AMOUNTS TO DN2G WITHOUT THE SUBROUTINE PARAMETER CALCJ.

#endif /* PORT_H_ */
