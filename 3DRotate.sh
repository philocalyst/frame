#!/bin/bash
#
# Developed by Fred Weinhaus 8/18/2007 .......... revised 10/25/2020
#
# ------------------------------------------------------------------------------
# 
# Licensing:
# 
# Copyright © Fred Weinhaus
# 
# My scripts are available free of charge for non-commercial use, ONLY.
# 
# For use of my scripts in commercial (for-profit) environments or 
# non-free applications, please contact me (Fred Weinhaus) for 
# licensing arrangements. My email address is fmw at alink dot net.
# 
# If you: 1) redistribute, 2) incorporate any of these scripts into other 
# free applications or 3) reprogram them in another scripting language, 
# then you must contact me for permission, especially if the result might 
# be used in a commercial or for-profit environment.
# 
# My scripts are also subject, in a subordinate manner, to the ImageMagick 
# license, which can be found at: http://www.imagemagick.org/script/license.php
# 
# ------------------------------------------------------------------------------
# 
####
#
# USAGE: 3Drotate option=value infile outfile
# USAGE: 3Drotate [-h or -help]
#
# OPTIONS:  any one or more
#
# pan      value     rotation about image vertical centerline; 
#                    -180 to +180 (deg); default=0
# tilt     value     rotation about image horizontal centerline; 
#                    -180 to +180 (deg); default=0
# roll     value     rotation about the image center; 
#                    -180 to +180 (deg); default=0
# pef      value     perspective exaggeration factor; 
#                    0 to 3.19; default=1
# idx  	   value     +/- pixel displacement in rotation point right/left 
#                    in input from center; default=0
# idy      value     +/- pixel displacement in rotation point down/up 
#                    in input from center; default=0
# odx      value     +/- pixel displacement in rotation point right/left 
#                    in output from center; default=0
# ody      value     +/- pixel displacement in rotation point down/up 
#                    in output from center; default=0
# zoom     value     output zoom factor; where value > 1 means zoom in 
#                    and < -1 means zoom out; value=1 means no change
# bgcolor  value     the background color value; any valid IM image 
#                    color specification (see -fill); default is black
# skycolor value     the sky color value; any valid IM image 
#                    color specification (see -fill); default is black
# auto     c         center bounding box in output 
#                    (odx and ody ignored)
# auto     zc        zoom to fill and center bounding box in output 
#                    (odx, ody and zoom ignored)
# auto     out       creates an output image of size needed to hold 
#                    the transformed image; (odx, ody and zoom ignored)
# vp       value     virtual-pixel method; any valid IM virtual-pixel method; 
#                    default=background
#
###
#
# NAME: 3DROTATE 
# 
# PURPOSE: To apply a perspective distortion to an image by providing rotation angles,
# zoom, offsets, background color, perspective exaggeration and auto zoom/centering. 
# 
# DESCRIPTION: 3DROTATE applies a perspective distortion to an image 
# by providing any combination of three optional rotation angle: 
# pan, tilt and roll with optional offsets and zoom and with an optional 
# control of the perspective exaggeration. The image is treated as if it 
# were painted on the Z=0 ground plane. The picture plane is then rotated 
# and then perspectively projected to a camera located a distance equal to 
# the focal length above the ground plane looking straight down along
# the -Z direction.
# 
# 
# ARGUMENTS: 
# 
# PAN is a rotation of the image about its vertical 
# centerline -180 to +180 degrees. Positive rotations turn the 
# right side of the image away from the viewer and the left side 
# towards the viewer. Zero is no rotation. A PAN of +/- 180 deg 
# achieves the same results as -flip.
# 
# TILT is a rotation of the image about its horizontal 
# centerline -180 to +180 degrees. Positive rotations turn the top 
# of the image away from the viewer and the bottom towards the 
# viewer. Zero is no rotation. A TILT of +/- 180 deg 
# achieves the same results as -flop.
# 
# ROLL (like image rotation) is a rotation in the plane of the 
# the image -180 to +180 degrees. Positive values are clockwise 
# and negative values are counter-clockwise. Zero is no rotation. 
# A ROLL of any angle achieves the same results as -rotate. 
# 
# PAN, TILT and ROLL are order dependent. If all three are provided, 
# then they will be done in whatever order specified.
# 
# PEF is the perspective exaggeration factor. It ranges from 0 to 3.19. 
# A normal perspective is achieved with the default of 1. As PEF is 
# increased from 1, the perspective effect moves towards that of 
# a wide angle lens (more distortion). If PEF is decreased from 1 
# the perspective effect moves towards a telephoto lens (less 
# distortion). PEF of 0.5 achieves an effect close to no perspective 
# distortion. As pef gets gets larger than some value which depends 
# upon the larger the pan, tilt and roll angles become, one reaches 
# a point where some parts of the picture become so distorted that 
# they wrap around and appear above the "horizon"
# 
# IDX is the a pixel displacement of the rotation point in the input image 
# from the image center. Positive values shift to the right along the 
# sample direction; negative values shift to the left. The default=0 
# corresponds to the image center.
#
# IDY is the a pixel displacement of the rotation point in the input image 
# from the image center. Positive values shift to downward along the 
# line direction; negative values shift upward. The default=0 
# corresponds to the image center.
#
# ODX is the a pixel displacement from the center of the output image where 
# one wants the corresponding input image rotation point to appear. 
# Positive values shift to the right along the sample direction; negative 
# values shift to the left. The default=0 corresponds to the output image center.
#
# ODY is the a pixel displacement from the center of the output image where 
# one wants the corresponding input image rotation point to appear. 
# Positive values shift downward along the sample direction; negative 
# values shift upward. The default=0 corresponds to the output image center.
#
# ZOOM is the output image zoom factor. Values > 1 (zoomin) cause the image 
# to appear closer; whereas values < 1 (zoomout) cause the image to 
# appear further away.
#
# BGCOLOR is the color of the background to use to fill where the output image 
# is outside the area of the perspective of the input image. See the IM function 
# -fill for color specifications. Note that when using rgb(r,g,b), this must be 
# enclosed in quotes after the equal sign.
#
# SKYCOLOR is the color to use in the 'sky' area above the perspective 'horizon'. 
# See the IM function -fill for color specifications. Note that when using 
# rgb(r,g,b), this must be enclosed in quotes after the equal sign.
#
# AUTO can be either c, zc or out. If auto is c, then the resulting perspective  
# of the input image will have its bounding box centered in the output image 
# whose size will be the same as the input image. If 
# auto is zc, then the resulting perspective of the input image will have its 
# bounding box zoomed to fill its largest dimension to match the size of the 
# the input image and the other dimension will be centered in the output. If
# auto is out, then the output image will be made as large or as small as 
# needed to just fill out the transformed input image. If any of these are 
# present, then the arguments OSHIFTX, OSHIFTY are ignored.
#
# VP is the virtual-pixel method, which allows the image to be extended outside 
# its bounds. For example, vp=background, then the background color is used to 
# fill the area in the output image which is outside the perspective view of 
# the input image. If vp=tile, then the perspective view will be tiled to fill 
# the output image.
#
# NOTE: The output image size will be the same as the input image size due 
# to current limitations on -distort Perspective.
#
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default value
# rotation angles and rotation matrix
pan=0
tilt=0
roll=0
R0=(1 0 0)
R1=(0 1 0)
R2=(0 0 1)

# scaling output only
sx=1
sy=1

# offset du,dv = output; relative to center of image
du=0
dv=0

# offset di,dj = input; relative to center of image
di=0
dj=0

# perspective exaggeration factor
pef=1

# zoom
zoom=1

# background color
bgcolor="black"

# sky color
skycolor="black"

# virtual-pixel method
vp="background"

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# compute pi
pi=`echo "scale=10; 4*a(1)" | bc -l`


# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}

# function to report error messages, usage and exit
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}

# function to do dot product of 2 three element vectors
function DP3
	{
	V0=($1)
	V1=($2)
	DP=`echo "scale=10; (${V0[0]} * ${V1[0]}) + (${V0[1]} * ${V1[1]}) + (${V0[2]} * ${V1[2]})" | bc`
	}

# function to do 3x3 matrix multiply M x N where input are rows of each matrix; M1 M2 M3 N1 N2 N3
function MM3
	{
	[ $# -ne 6 ] && errMsg "--- NOT A VALID SET OF MATRIX PARAMETERS ---"
	M0=($1)
	M1=($2)
	M2=($3)
	N0=($4)
	N1=($5)
	N2=($6)
	[ ${#M0[*]} -ne 3 -a ${#M1[*]} -ne 3 -a ${#M2[*]} -ne 3 -a ${#N0[*]} -ne 3 -a ${#N1[*]} -ne 3 -a ${#N2[*]} -ne 3 ] && errMsg "--- NOT A VALID SET OF MATRIX ROWS ---"
	# extract columns n from rows N
	n0=(${N0[0]} ${N1[0]} ${N2[0]})
	n1=(${N0[1]} ${N1[1]} ${N2[1]})
	n2=(${N0[2]} ${N1[2]} ${N2[2]})
	DP3 "${M0[*]}" "${n0[*]}"
	P00=$DP
	DP3 "${M0[*]}" "${n1[*]}"
	P01=$DP
	DP3 "${M0[*]}" "${n2[*]}"
	P02=$DP
	DP3 "${M1[*]}" "${n0[*]}"
	P10=$DP
	DP3 "${M1[*]}" "${n1[*]}"
	P11=$DP
	DP3 "${M1[*]}" "${n2[*]}"
	P12=$DP
	DP3 "${M2[*]}" "${n0[*]}"
	P20=$DP
	DP3 "${M2[*]}" "${n1[*]}"
	P21=$DP
	DP3 "${M2[*]}" "${n2[*]}"
	P22=$DP
	P0=($P00 $P01 $P02)
	P1=($P10 $P11 $P12)
	P2=($P20 $P21 $P22)
	}

# function to project points from input to output domain
function forwardProject
	{
	ii=$1
	jj=$2
	numu=`echo "scale=10; ($P00 * $ii) + ($P01 * $jj) + $P02" | bc`
	numv=`echo "scale=10; ($P10 * $ii) + ($P11 * $jj) + $P12" | bc`
	den=`echo "scale=10; ($P20 * $ii) + ($P21 * $jj) + $P22" | bc`
	uu=`echo "scale=0; $numu / $den" | bc`
	vv=`echo "scale=0; $numv / $den" | bc`
	}

# function to project points from input to output domain
function inverseProject
	{
	uu=$1
	vv=$2
	numi=`echo "scale=10; ($Q00 * $uu) + ($Q01 * $vv) + $Q02" | bc`
	numj=`echo "scale=10; ($Q10 * $uu) + ($Q11 * $vv) + $Q12" | bc`
	den=`echo "scale=10; ($Q20 * $uu) + ($Q21 * $vv) + $Q22" | bc`
	ii=`echo "scale=0; $numi / $den" | bc`
	jj=`echo "scale=0; $numj / $den" | bc`
	}

# function to invert a 3 x 3 matrix using method of adjoint
# inverse is the transpose of the matrix of cofactors divided by the determinant
function M3inverse
	{
	m00=$1
	m01=$2
	m02=$3
	m10=$4
	m11=$5
	m12=$6
	m20=$7
	m21=$8
	m22=$9
	c00=`echo "scale=10; ($m11 * $m22) - ($m21 * $m12)" | bc`
	c01=`echo "scale=10; ($m20 * $m12) - ($m10 * $m22)" | bc`
	c02=`echo "scale=10; ($m10 * $m21) - ($m20 * $m11)" | bc`
	c10=`echo "scale=10; ($m21 * $m02) - ($m01 * $m22)" | bc`
	c11=`echo "scale=10; ($m00 * $m22) - ($m20 * $m02)" | bc`
	c12=`echo "scale=10; ($m20 * $m01) - ($m00 * $m21)" | bc`
	c20=`echo "scale=10; ($m01 * $m12) - ($m11 * $m02)" | bc`
	c21=`echo "scale=10; ($m10 * $m02) - ($m00 * $m12)" | bc`
	c22=`echo "scale=10; ($m00 * $m11) - ($m10 * $m01)" | bc`
	det=`echo "scale=10; ($m00 * $c00) + ($m01 * $c01) + ($m02 * $c02)" | bc`
	idet=`echo "scale=10; 1 / $det" | bc`
	Q00=`echo "scale=10; $c00 * $idet" | bc`
	Q01=`echo "scale=10; $c10 * $idet" | bc`
	Q02=`echo "scale=10; $c20 * $idet" | bc`
	Q10=`echo "scale=10; $c01 * $idet" | bc`
	Q11=`echo "scale=10; $c11 * $idet" | bc`
	Q12=`echo "scale=10; $c21 * $idet" | bc`
	Q20=`echo "scale=10; $c02 * $idet" | bc`
	Q21=`echo "scale=10; $c12 * $idet" | bc`
	Q22=`echo "scale=10; $c22 * $idet" | bc`
	Q0=($Q00 $Q01 $Q02)
	Q1=($Q10 $Q11 $Q12)
	Q2=($Q20 $Q21 $Q22)
	}

# function to test if entry is floating point number
function testFloat
	{
	test1=`expr "$1" : '[0-9][0-9]*'`  				# counts same as above but preceeded by plus or minus
	test2=`expr "$1" : '[+-][0-9][0-9]*'`  			# counts one or more digits
	test3=`expr "$1" : '[0-9]*[\.][0-9]*'`			# counts 0 or more digits followed by period followed by 0 or more digits
	test4=`expr "$1" : '[+-][0-9]*[\.][0-9]*'`		# counts same as above but preceeded by plus or minus
	floatresult=`expr $test1 + $test2 + $test3 + $test4`
#	[ $floatresult = 0 ] && errMsg "THE ENTRY $1 IS NOT A FLOATING POINT NUMBER"
	}

# get input image size
function imagesize
	{
	width=`vipsheader -f width $tmpA`
	height=`vipsheader -f height $tmpA`
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 15 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -h|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		   pan[=]*)    # pan angle
					   arg="$1="
					   pan=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   pan=`echo "$pan" | sed 's/^[+]\(.*\)$/\1/'`
					   # pantest>0 if floating point number; otherwise pantest=0
					   testFloat "$pan"; pantest=$floatresult
					   pantestA=`echo "$pan < - 180" | bc`
					   pantestB=`echo "$pan > 180" | bc`
					   [ $pantest -eq 0 ] && errMsg "PAN=$pan IS NOT A NUMBER"
					   [ $pantestA -eq 1 -o $pantestB -eq 1 ] && errMsg "PAN=$pan MUST BE GREATER THAN -180 AND LESS THAN +180"
					   panang=`echo "scale=10; $pi * $pan / 180" | bc`
					   sinpan=`echo "scale=10; s($panang)" | bc -l`
					   sinpanm=`echo "scale=10; - $sinpan" | bc`
					   cospan=`echo "scale=10; c($panang)" | bc -l`
					   Rp0=($cospan 0 $sinpan)
					   Rp1=(0 1 0)
					   Rp2=($sinpanm 0 $cospan)
					   # do matrix multiply to get new rotation matrix
					   MM3 "${Rp0[*]}" "${Rp1[*]}" "${Rp2[*]}" "${R0[*]}" "${R1[*]}" "${R2[*]}"
					   R0=(${P0[*]})
					   R1=(${P1[*]})
					   R2=(${P2[*]})
					   ;;
		  tilt[=]*)    # tilt angle
					   arg="$1="
					   tilt=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   tilt=`echo "$tilt" | sed 's/^[+]\(.*\)$/\1/'`
					   # tilttest>0 if floating point number; otherwise tilttest=0
					   testFloat "$tilt"; tilttest=$floatresult
					   tilttestA=`echo "$tilt < - 180" | bc`
					   tilttestB=`echo "$tilt > 180" | bc`
					   [ $tilttest -eq 0 ] && errMsg "tilt=$tilt IS NOT A NUMBER"
					   [ $tilttestA -eq 1 -o $tilttestB -eq 1 ] && errMsg "TILT=$tilt MUST BE GREATER THAN -180 AND LESS THAN +180"
					   tiltang=`echo "scale=10; $pi * $tilt / 180" | bc`
					   sintilt=`echo "scale=10; s($tiltang)" | bc -l`
					   sintiltm=`echo "scale=10; - $sintilt" | bc`
					   costilt=`echo "scale=10; c($tiltang)" | bc -l`
					   Rt0=(1 0 0)
					   Rt1=(0 $costilt $sintilt)
					   Rt2=(0 $sintiltm $costilt)
					   # do matrix multiply to get new rotation matrix
					   MM3 "${Rt0[*]}" "${Rt1[*]}" "${Rt2[*]}" "${R0[*]}" "${R1[*]}" "${R2[*]}"
					   R0=(${P0[*]})
					   R1=(${P1[*]})
					   R2=(${P2[*]})
					   ;;
		  roll[=]*)    # roll angle
					   arg="$1="
					   roll=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   roll=`echo "$roll" | sed 's/^[+]\(.*\)$/\1/'`
					   # rolltest>0 if floating point number; otherwise rolltest=0
					   testFloat "$roll"; rolltest=$floatresult
					   rolltestA=`echo "$roll < - 180" | bc`
					   rolltestB=`echo "$roll > 180" | bc`
					   [ $rolltest -eq 0 ] && errMsg "roll=$roll IS NOT A NUMBER"
					   [ $rolltestA -eq 1 -o $rolltestB -eq 1 ] && errMsg "ROLL=$roll MUST BE GREATER THAN -180 AND LESS THAN +180"
					   rollang=`echo "scale=10; $pi * $roll / 180" | bc`
					   sinroll=`echo "scale=10; s($rollang)" | bc -l`
					   sinrollm=`echo "scale=10; - $sinroll" | bc`
					   cosroll=`echo "scale=10; c($rollang)" | bc -l`
					   Rr0=($cosroll $sinroll 0)
					   Rr1=($sinrollm $cosroll 0)
					   Rr2=(0 0 1)
					   # do matrix multiply to get new rotation matrix
					   MM3 "${Rr0[*]}" "${Rr1[*]}" "${Rr2[*]}" "${R0[*]}" "${R1[*]}" "${R2[*]}"
					   R0=(${P0[*]})
					   R1=(${P1[*]})
					   R2=(${P2[*]})
					   ;;
		   pef[=]*)    # pef
					   arg="$1="
					   pef=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   pef=`echo "$pef" | sed 's/^[+]\(.*\)$/\1/'`
					   # peftest>0 if floating point number; otherwise peftest=0
					   testFloat "$pef"; peftest=$floatresult
					   peftestA=`echo "$pef < 0" | bc`
					   peftestB=`echo "$pef > 3.19" | bc`
					   [ $peftest -eq 0 ] && errMsg "PEF=$pef IS NOT A NUMBER"
					   ;;
	       idx[=]*)    # input x shift
					   arg="$1="
					   di=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   di=`echo "$di" | sed 's/^[+]\(.*\)$/\1/'`
					   # ditest>0 if floating point number; otherwise ditest=0
					   testFloat "$di"; ditest=$floatresult
					   [ $ditest -eq 0 ] && errMsg "ISHIFTX=$di IS NOT A NUMBER"
					   ;;
	       idy[=]*)    # input y shift
					   arg="$1="
					   dj=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   dj=`echo "$dj" | sed 's/^[+]\(.*\)$/\1/'`
					   # djtest>0 if floating point number; otherwise ditest=0
					   testFloat "$dj"; djtest=$floatresult
					   [ $djtest -eq 0 ] && errMsg "ISHIFTY=$dj IS NOT A NUMBER"
					   ;;
	       odx[=]*)    # output x shift
					   arg="$1="
					   du=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   du=`echo "$du" | sed 's/^[+]\(.*\)$/\1/'`
					   # dutest>0 if floating point number; otherwise ditest=0
					   testFloat "$du"; dutest=$floatresult
					   [ $dutest -eq 0 ] && errMsg "OSHIFTX=$du IS NOT A NUMBER"
					   ;;
	       ody[=]*)    # output y shift
					   arg="$1="
					   dv=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   dv=`echo "$dv" | sed 's/^[+]\(.*\)$/\1/'`
					   # dvtest>0 if floating point number; otherwise ditest=0
					   testFloat "$dv"; dvtest=$floatresult
					   [ $dvtest -eq 0 ] && errMsg "OSHIFTY=$dv IS NOT A NUMBER"
					   ;;
		  zoom[=]*)    # output zoom
					   arg="$1="
					   zoom=`echo "$arg" | cut -d= -f2`
					   # function bc does not seem to like numbers starting with + sign, so strip off
					   zoom=`echo "$zoom" | sed 's/^[+]\(.*\)$/\1/'`
					   # zoomtest>0 if floating point number; otherwise peftest=0
					   testFloat "$zoom"; zoomtest=$floatresult
					   zoomtest=`echo "$zoom < 1 && $zoom > -1" | bc`
					   [ $zoomtest -eq 1 ] && errMsg "ZOOM=$zoom MUST BE GREATER THAN 1 OR LESS THAN -1"
					   ;;
	   bgcolor[=]*)    # output background color
					   arg="$1="
					   bgcolor=`echo "$arg" | cut -d= -f2`
					   ;;
	  skycolor[=]*)    # output sky color
					   arg="$1="
					   skycolor=`echo "$arg" | cut -d= -f2`
					   ;;
	        vp[=]*)    # virtual pixel method
					   arg="$1="
					   vp=`echo "$arg" | cut -d= -f2`
					   [ "$vp" != "background" -a "$vp" != "dither" -a "$vp" != "edge" -a "$vp" != "mirror" -a "$vp" != "random" -a "$vp" != "tile" -a "$vp" != "transparent" -a "$vp" != "none" ] && errMsg "VP=$vp IS NOT A VALID VALUE"
					   ;;
	   	  auto[=]*)    # output background color
					   arg="$1="
					   auto=`echo "$arg" | cut -d= -f2`
					   [ "$auto" != "c" -a "$auto" != "zc" -a "$auto" != "out" ] && errMsg "AUTO=$auto IS NOT A VALID VALUE"
					   ;;
		     *[=]*)    # not valid
					   errMsg "$1 IS NOT A VALID ARGUMENT"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi

# setup temporary images and auto delete upon exit
# use mpc/cache to hold input image temporarily in memory
tmpA="$dir/3Drotate_$$.mpc"
tmpB="$dir/3Drotate_$$.cache"
trap "rm -f $tmpA $tmpB;" 0
trap "rm -f $tmpA $tmpB; exit 1" 1 2 3 15
trap "rm -f $tmpA $tmpB; exit 1" ERR

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"
# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"

if magick -quiet "$infile" +repage "$tmpA"
	then
	[ "$pef" = "" ] && pef=1
else
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE ---"
fi

# get input image width and height
imagesize
maxwidth=`expr $width - 1`
maxheight=`expr $height - 1`

# deal with auto adjustments to values
if [ "$auto" = "zc" ]
	then 
	du=0
	dv=0
	zoom=1
elif [ "$auto" = "c" ]
	then 
	du=0
	dv=0
fi

# convert offsets of rotation point to relative to pixel 0,0
di=`echo "scale=10; ($di + (($width - 1) / 2)) / 1" | bc`
dj=`echo "scale=10; ($dj + (($height - 1) / 2)) / 1" | bc`
du=`echo "scale=10; $du / 1" | bc`
dv=`echo "scale=10; $dv / 1" | bc`

# convert zoom to scale factors
if [ `echo "$zoom >= 1" | bc` -eq 1 ]
	then
	sx=`echo "scale=10; 1 / $zoom" | bc`
	sy=$sx
elif [ `echo "$zoom <= -1" | bc` -eq 1 ]
	then
	sx=`echo "scale=10; - $zoom / 1" | bc`
	sy=$sx
fi

# Consider the picture placed on the Z=0 plane and the camera a distance
# Zc=f above the picture plane looking straight down at the image center.
# Now the perspective equations (in 3-D) are defined as (x,y,f) = M (X',Y',Z'),
# where the camera orientation matrix M is the identity matrix but with M22=-1
# because the camera is looking straight down along -Z. 
# Thus a reflection transformation relative to the ground plane coordinates.
# Let the camera position Zc=f=(sqrt(ins*ins + inl*inl)) / ( 2 tan(fov/2) )
# Now we want to rotate the ground points corresponding to the picture corners.
# The basic rotation is (X',Y',Z') = R (X,Y,0), where R is the rotation matrix
# involving pan, tilt and roll.
# But we need to convert (X,Y,0) to (X,Y,1) and also to offset for Zc=f
# First we note that (X,Y,0) = (X,Y,1) - (0,0,1)
# Thus the equation becomes (x,y,f) = M {R [(X,Y,1) - (0,0,1)] - (0,0,Zc)} = MT (X,Y,1)
# But R [(X,Y,1) - (0,0,1)] = R [II (X,Y,1) - S (X,Y,1)] = R (II-S) (X,Y,1), where
# II is the identity matrix and S is an all zero matrix except for S22=1.
# Thus (II-S) is the identity matrix with I22=0 and 
# RR = R (II-S) is just R with the third column all zeros.
# Thus we get (x,y,f) = M {RR (X,Y,1) - (0,0,Zc)}.
# But M {RR (X,Y,1) - (0,0,Zc)} = M {RR(X,Y,1) - D (X,Y,1)}, where 
# D is an all zero matrix with D22 = Zc = f. 
# So that we get M (RR-D) (X,Y,1) = MT (X,Y,1), where
# where T is just R with the third column (0,0,-f), i.e. T02=0, T12=0, T22=-f
# But we need to allow for scaling and offset of the output coordinates and
# conversion from (x,y,f) to (u,v,1)=O and conversion of input coordinates 
# from (X,Y,1) to (i,j,1)=I.
# Thus the forward transformation becomes AO=MTBI or O=A'MTBI or O=PI, 
# where prime means inverse.
# However, to do the scaling of the output correctly, need to offset by the input 
# plus output offsets, then scale, which is all put into A'.
# Thus the forward transformation becomes AO=MTBI or O=A'MTBI where A'=Ai
# but we will merge A'M into Aim
# Thus the inverse transform becomes
# I=QO where Q=P'
# A=output scaling, offset and conversion matrix
# B=input offset and conversion matrix (scaling only needs to be done in one place)
# M=camera orientation matrix
# R=image rotation matrix Rroll Rtilt Rpan
# T=matrix that is R but R33 offset by f + 1
# O=output coords vector (i,j,1)
# I=input coords vector (u,v,1)=(is,il,1)
# P=forward perspective transformation matrix
# Q=inverse perspective transformation matrix
#
# For a 35 mm camera whose film format is 36mm wide and 24mm tall, when the focal length 
# is equal to the diagonal, the field of view is 53.13 degrees and this is 
# considered a normal view equivalent to the human eye.
# See http://www.panoramafactory.com/equiv35/equiv35.html
# Max limit on dfov is 180 degrees (pef=3.19) where get single line like looking at picture on edge.
# Above this limit the picture becomes like the angles get reversed.
# Min limit on dfov seems to be slightly greater than zero degrees.
# Practical limits on dfov depend upon orientation angles.
# For tilt=45, this is about 2.5 dfov (pef=2.5). Above this, some parts of the picture 
# that are cut off at the bottom, get wrapped and stretched in the 'sky'.

dfov=`echo "scale=10; 180 * a(36/24) / $pi" | bc -l`
if [ "$pef" = "" ]
	then
	pfact=1
elif [ "$pef" = "0" ]
	then
	pfact=`echo "scale=10; 0.01 / $dfov" | bc`
else
	pfact=$pef
fi
#maxpef=`echo "scale=5; 180 / $dfov" | bc`
#echo "maxpef=$maxpef"

#compute new field of view based upon pef (pfact)
dfov=`echo "scale=10; $pfact * $dfov" | bc`
dfov2=`echo "scale=10; $dfov / 2" | bc`
arg=`echo "scale=10; $pi * $dfov2 / 180" | bc`
sfov=`echo "scale=10; s($arg)" | bc -l`
cfov=`echo "scale=10; c($arg)" | bc -l`
tfov=`echo "scale=10; $sfov / $cfov" | bc -l`
#echo "tfov=$tfov"

# calculate focal length in same units as wall (picture) using dfov
diag=`echo "scale=10; sqrt(($width * $width) + ($height * $height))" | bc`
focal=`echo "scale=10; ($diag / (2 * $tfov))" | bc -l`
#echo "focal=$focal"

# calculate forward transform matrix Q

# define the input offset and conversion matrix
dim=`echo "scale=10; - $di" | bc`
B0=(1 0 $dim)
B1=(0 -1 $dj)
B2=(0 0 1)

# define the output scaling, offset and conversion matrix inverse Ai and merge with M
# to become Aim
#A0=($sx 0 $sx*(-$du-$di))
#A1=(0 -$sy $sy*($dv+$dj))
#A2=(0 0 -$focal)
#M0=(1 0 0)
#M1=(0 1 0)
#M2=(0 0 -1)
aim00=`echo "scale=10; 1 / $sx" | bc`
aim02=`echo "scale=10; -($sx * ($di + $du)) / ($sx * $focal)" | bc`
aim11=`echo "scale=10; -1 / $sy" | bc`
aim12=`echo "scale=10; -($sy * ($dj + $dv)) / ($sy * $focal)" | bc`
aim22=`echo "scale=10; -1 / $focal" | bc`
Aim0=($aim00 0 $aim02)
Aim1=(0 $aim11 $aim12)
Aim2=(0 0 $aim22)

# now do successive matrix multiplies from right towards left of main equation P=A'RB

# convert R to T by setting T02=T12=0 and T22=-f
focalm=`echo "scale=10; - $focal" | bc`
T0=(${R0[0]} ${R0[1]} 0)
T1=(${R1[0]} ${R1[1]} 0)
T2=(${R2[0]} ${R2[1]} $focalm)

# multiply T x B = P
MM3 "${T0[*]}" "${T1[*]}" "${T2[*]}" "${B0[*]}" "${B1[*]}" "${B2[*]}"

# multiply Aim x P = P
MM3 "${Aim0[*]}" "${Aim1[*]}" "${Aim2[*]}" "${P0[*]}" "${P1[*]}" "${P2[*]}"

# the resulting P matrix is now the perspective coefficients for the inverse transformation
P00=${P0[0]}
P01=${P0[1]}
P02=${P0[2]}
P10=${P1[0]}
P11=${P1[1]}
P12=${P1[2]}
P20=${P2[0]}
P21=${P2[1]}
P22=${P2[2]}

# project input corners to output domain
#echo "UL"
i=0
j=0
#echo "i,j=$i,$j"
forwardProject $i $j
#echo "u,v=$uu,$vv"
u1=$uu
v1=$vv
#echo "UR"
i=$maxwidth
j=0
#echo "i,j=$i,$j"
forwardProject $i $j
#echo "u,v=$uu,$vv"
u2=$uu
v2=$vv
#echo "BR"
i=$maxwidth
j=$maxheight
#echo "i,j=$i,$j"
forwardProject $i $j
#echo "u,v=$uu,$vv"
u3=$uu
v3=$vv
#echo "BL"
i=0
j=$maxheight
#echo "i,j=$i,$j"
forwardProject $i $j
#echo "u,v=$uu,$vv"
u4=$uu
v4=$vv
#echo "C"
#i=`echo "scale=10; $maxwidth / 2" | bc`
#j=`echo "scale=10; $maxheight / 2" | bc`
#echo "i,j=$i,$j"
#forwardProject $i $j
#echo "u,v=$uu,$vv"
#u5=$uu
#v5=$vv

# unused
: '
# Now invert P to get Q for the inverse perspective transformation
# Use the Method of the Adjoint Matrix = transpose of matrix of cofactors divided by the determinant
# M3inverse $P00 $P01 $P02 $P10 $P11 $P12 $P20 $P21 $P22
#
# project output corners to input domain
# UL
#echo "UL 0,0"
#u=$u1
#v=$v1
#echo "u,v=$u,$v"
#inverseProject $u $v
#echo "i,j=$ii,$jj"
#echo "UR 255,0"
#u=$u2
#v=$v2
#echo "u,v=$u,$v"
#inverseProject $u $v
#echo "i,j=$ii,$jj"
#echo "BR 255,255"
#u=$u3
#v=$v3
#echo "u,v=$u,$v"
#inverseProject $u $v
#echo "i,j=$ii,$jj"
#echo "BL 0,255"
#u=$u4
#v=$v4
#echo "u,v=$u,$v"
#inverseProject $u $v
#echo "i,j=$ii,$jj"
#echo "C 127.5,127.5"
#u=$u5
#v=$v5
#echo "u,v=$u,$v"
#inverseProject $u $v
#echo "i,j=$ii,$jj"
'

# deal with adjustments for auto settings
# first get the bounding box dimensions
uArr=($u1 $u2 $u3 $u4)
vArr=($v1 $v2 $v3 $v4)
index=0
umin=1000000
umax=-1000000
vmin=1000000
vmax=-1000000
while [ $index -lt 4 ]
	do
	[ `echo "${uArr[$index]} < $umin" | bc` -eq 1 ] && umin=${uArr[$index]}
	[ `echo "${uArr[$index]} > $umax" | bc` -eq 1 ] && umax=${uArr[$index]}
	[ `echo "${vArr[$index]} < $vmin" | bc` -eq 1 ] && vmin=${vArr[$index]}
	[ `echo "${vArr[$index]} > $vmax" | bc` -eq 1 ] && vmax=${vArr[$index]}
	index=`expr $index + 1`
done
delu=`echo "scale=10; $umax - $umin + 1" | bc`
delv=`echo "scale=10; $vmax - $vmin + 1" | bc`
if [ "$auto" = "c" ]
	then
	offsetu=`echo "scale=10; ($width - $delu) / 2" | bc`
	offsetv=`echo "scale=10; ($height - $delv) / 2" | bc`
	u1=`echo "scale=0; $offsetu + ($u1 - $umin)" | bc`
	v1=`echo "scale=0; $offsetv + ($v1 - $vmin)" | bc`
	u2=`echo "scale=0; $offsetu + ($u2 - $umin)" | bc`
	v2=`echo "scale=0; $offsetv + ($v2 - $vmin)" | bc`
	u3=`echo "scale=0; $offsetu + ($u3 - $umin)" | bc`
	v3=`echo "scale=0; $offsetv + ($v3 - $vmin)" | bc`
	u4=`echo "scale=0; $offsetu + ($u4 - $umin)" | bc`
	v4=`echo "scale=0; $offsetv + ($v4 - $vmin)" | bc`
elif [ "$auto" = "zc" ]
	then
	if [ `echo "$delu > $delv" | bc` -eq 1 ]
		then 
		del=$delu
		offsetu=0
		offsetv=`echo "scale=10; ($height - ($delv * $width / $delu)) / 2" | bc`
	else
		del=$delv
		offsetu=`echo "scale=10; ($width - ($delu * $height / $delv)) / 2" | bc`
		offsetv=0
	fi
	u1=`echo "scale=0; $offsetu + (($u1 - $umin) * $width / $del)" | bc`
	v1=`echo "scale=0; $offsetv + (($v1 - $vmin) * $height / $del)" | bc`
	u2=`echo "scale=0; $offsetu + (($u2 - $umin) * $width / $del)" | bc`
	v2=`echo "scale=0; $offsetv + (($v2 - $vmin) * $height / $del)" | bc`
	u3=`echo "scale=0; $offsetu + (($u3 - $umin) * $width / $del)" | bc`
	v3=`echo "scale=0; $offsetv + (($v3 - $vmin) * $height / $del)" | bc`
	u4=`echo "scale=0; $offsetu + (($u4 - $umin) * $width / $del)" | bc`
	v4=`echo "scale=0; $offsetv + (($v4 - $vmin) * $height / $del)" | bc`
fi
#
# now do the perspective distort
if [ "$auto" = "out" ]
	then
	distort="+distort"
else
	distort="-distort"
fi

im_version=`magick -list configure | \
	sed '/^LIB_VERSION_NUMBER */!d; s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g' | head -n 1`

# set up $matting
if [ "$im_version" -ge "070000000" -a "$im_version" -le "07000409" ]
	then
	matting="-alpha-color"
else
	matting="-mattecolor"
fi


if [ "$im_version" -lt "06030600" ]
	then
	magick $tmpA -virtual-pixel $vp -background $bgcolor \
	$matting $skycolor $distort Perspective \
	"0,0 $maxwidth,0 $maxwidth,$maxheight 0,$maxheight  $u1,$v1 $u2,$v2 $u3,$v3 $u4,$v4" "$outfile"
else
	magick $tmpA -virtual-pixel $vp -background $bgcolor \
	$matting $skycolor $distort Perspective \
	"0,0 $u1,$v1   $maxwidth,0 $u2,$v2   $maxwidth,$maxheight $u3,$v3   0,$maxheight $u4,$v4" "$outfile"
fi
exit 0
