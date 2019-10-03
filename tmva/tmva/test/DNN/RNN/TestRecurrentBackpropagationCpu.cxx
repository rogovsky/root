// @(#)root/tmva $Id$
// Author: Saurav Shekhar 16/02/17

/*************************************************************************
 * Copyright (C) 2017, Saurav Shekhar                                    *
 * All rights reserved.                                                  *
 *                                                                       *
 * For the licensing terms see $ROOTSYS/LICENSE.                         *
 * For the list of contributors see $ROOTSYS/README/CREDITS.             *
 *************************************************************************/

////////////////////////////////////////////////////////////////////
// Testing RNNLayer backpropagation                               //
////////////////////////////////////////////////////////////////////

#include <iostream>
#include "TMVA/DNN/Architectures/Cpu.h"
#include "TestRecurrentBackpropagation.h"
#include "TROOT.h"

using namespace TMVA::DNN;
using namespace TMVA::DNN::RNN;

int main() {
   std::cout << "Testing RNN backward pass\n";

   //ROOT::EnableImplicitMT(1);
   
   using Scalar_t = Double_t;

   // timesteps, batchsize, statesize, inputsize  { fixed input, with dense layer, with extra RNN }

   testRecurrentBackpropagation<TCpu<Scalar_t>>(1, 2, 1, 2, 1e-5);

   testRecurrentBackpropagation<TCpu<Scalar_t>>(1, 2, 3, 2, 1e-5); 

   testRecurrentBackpropagation<TCpu<Scalar_t>>(2, 3, 4, 5, 1e-5);

   testRecurrentBackpropagation<TCpu<Scalar_t>>(4, 2, 10, 5, 1e-5);
//   testRecurrentBackpropagation<TCpu<Scalar_t>>(4, 2, 5, 4, 1e-5, true, false, true);

   testRecurrentBackpropagation<TCpu<Scalar_t>>(5, 64, 10, 5, 1e-5);


   // using a fixed input 
   testRecurrentBackpropagation<TCpu<Scalar_t>>(3, 1, 10, 5, 1e-5, {true});

   // with a dense layer 
   testRecurrentBackpropagation<TCpu<Scalar_t>>(4, 32, 10, 20, 1e-5, {false, true});

   // with an additional RNN layer 
   testRecurrentBackpropagation<TCpu<Scalar_t>>(4, 32, 10, 5, 1e-5, {false, true, true});


   return 0;
}
