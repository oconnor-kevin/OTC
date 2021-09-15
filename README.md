# OTC

This repository contains the code from the paper "Optimal Transport for Stationary Markov Chains via Policy Iteration" by O'Connor et al. found [here](https://arxiv.org/abs/2006.07998). We provide a Matlab implementation of both the ExactOTC and EntropicOTC algorithms as well as the code to reproduce the experimental results described in the paper.

Most of the functions in the `ot_algorithms` folder are adaptations of functions provided [here](https://github.com/JasonAltschuler/OptimalTransportNIPS17). The code for training the classical music HMMs is adapted from code provided [here](https://github.com/aky4wn/Classical-Music-Composition-Using-State-Space-Models). MIDI files were converted to MP3 files using https://onlinesequencer.net/.


## Running ExactOTC and EntropicOTC
In order to run ExactOTC for transition matrices Px and Py with a cost matrix c, simply run

```
[exp_cost, P, ~] = exact_otc(Px, Py, c, 0)
```

Note that the last argument indicates whether the runs should be timed. If you would like to time each iteration, run

```
[exp_cost, P, times] = exact_otc(Px, Py, c, 1)
```

Similarly, if you wish to run EntropicOTC with parameters xi, L, T, and sink_iter, simply run

```
[exp_cost, P, ~] = entropic_otc(Px, Py, c, L, T, xi, sink_iter, 0)
```

Like the exact algorithm, the last argument may be switched to 1 to time each iteration.

## Reproducing Experimental Results
The code for reproducing the experimental results described in the paper are included in `run_time_experiment.m` and `music_experiment.m`. Any necessary parameters for either experiment may be set at the top of the respective script. After doing this, you can run the entire script to run the experiment. All relevant results will be saved automatically.

## Citing this Repo
If you wish to refer to our results or code, please cite our paper as follows:
```
@article{o2020optimal,
  title={Optimal Transport for Stationary Markov Chains via Policy Iteration},
  author={O'Connor, Kevin and McGoff, Kevin and Nobel, Andrew},
  journal={arXiv preprint arXiv:2006.07998},
  year={2020}
}
```
