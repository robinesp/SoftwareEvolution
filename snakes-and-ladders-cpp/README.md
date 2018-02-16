Snakes and Ladders Simulation
=============================

This is a small, simple and naiv simulation of a snakes and ladders game (also 
known as chutes and ladders); without ladders.

Dependencies
============

The simulation uses C++ with some C++11 features.

The only libraries used are:
 * stdio.h
 * random (C++11)

Linux
-----

Clone it or unpack it, then run make. This produces simbin. You can run it 
using './simbin'.

Flags and Options
=================

This program requires the size of the board as the first parameter. The 
program translates this argument into an int. It does not do much type 
checking, but will give warning if it is above a certain threshold (currently 
1000).

Licensing and Legalese
======================

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
