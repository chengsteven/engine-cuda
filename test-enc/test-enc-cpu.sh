#!/bin/bash
#
# @version 0.1.0 (2010)
# @author Paolo Margara <paolo.margara@gmail.com>
#
# Copyright 2010 Paolo Margara
#
# This file is part of Engine_cudamrg.
#
# Engine_cudamrg is free software. you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License or
# any later version.
#
# Engine_cudamrg is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTy ; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Engine_cudamrg.  If not, see <http.//www.gnu.org/licenses/>.
#
infile_e='./test'
outfile='/dev/null'
key='c26d8562740cdcea548efc08babd19a3d1aaedf6'
IV='ABCDEF'
cmd='/usr/bin/time -f %e openssl'

for cipher in aes-128-ecb aes-192-ecb aes-256-ecb aes-128-cbc aes-192-cbc aes-256-cbc aes-128-ctr aes-192-ctr aes-256-ctr
do
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize    4096 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   4K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize    8192 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   8K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize   16384 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #  16K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize   32768 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #  32K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize   65536 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #  64K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize  131072 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat # 128K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize  262144 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat # 256K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize  524288 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat # 512K
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize 1048576 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   1M
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize 2097151 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   2M
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize 4194304 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   4M
$cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.$cipher.aes -bufsize 8388608 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-cpu.dat #   8M
done

for cipher in aes-128-ecb aes-192-ecb aes-256-ecb aes-128-cbc aes-192-cbc aes-256-cbc aes-128-ctr aes-192-ctr aes-256-ctr
do
# $cmd enc -e -$cipher -v -iv $IV -in $infile_e -out $infile_e.aes -k $key
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize    4096 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   4K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize    8192 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   8K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize   16384 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #  16K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize   32768 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #  32K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize   65536 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #  64K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize  131072 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat # 128K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize  262144 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat # 256K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize  524288 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat # 512K
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize 1048576 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   1M
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize 2097151 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   2M
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize 4194304 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   4M
$cmd enc -d -$cipher -v -iv $IV -in $infile_e.$cipher.aes -out $outfile -bufsize 8388608 -k $key 2>&1 | grep "^[0-9]*[0-9]" > $cipher-decrypt-cpu.dat #   8M
rm -f $infile_e^[0-9]*[0-9].aes
done
