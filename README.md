run ./downloadfiles.sh, then timbre_explorer.py to create sounds
use timbre_explorer_mpi.py for multiple processors

The directory patch contains the supercollider code to explore the resultant sounds using a Leap Motion controller.

# Timbre interpolation explorer

This project contains two parts:
- Script used to create a 3D grid of different levels of interpolation between timbres of 3 different sound sources, found in project's root directory.
It uses the Machine Learning library [Magenta](https://magenta.tensorflow.org/).
- Interactive system used to explore resulting corpus of sounds by using a Leap Motion sensor, found in "patch" directory.

By [Héctor González Orozco](https://github.com/hectorgonzalezo)

## :computer: Built With

* [Python](https://www.python.org/)
* [Magenta](https://magenta.tensorflow.org/)
* [SuperCollider](https://supercollider.github.io/)
* [Leap Motion](https://www.ultraleap.com/product/leap-motion-controller/)


## :rocket: Features

- 3D timbre interpolation using pre-trained unsupervised learning neural network.

- Options to run script using single and multithreading.

- Interactive interface to explore sounds in virtual 3D space.


## :construction: Installing

1. Clone the repository

`git clone https://github.com/hectorgonzalezo/timbre_explorer`