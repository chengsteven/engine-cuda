#!/usr/bin/env zsh
# vim:ft=sh

ENC_CIPHERS=(aes-128-ecb aes-128-ctr )
DEC_CIPHERS=(aes-128-ecb aes-128-ctr )

# IV="FFFF"
# IV="0000000000000000"
# IV="ABCDEFABCDEF"
IV="DEADBEEFDEADBEEF"
BUFSIZE=8388608
OPENSSL=$HOME/local/bin/openssl
# TODO: Use getopt or zparseopts

if [[ $ARGC -lt 1 ]]; then
	echo " Usage: ./test-consistency.sh <file> <key> <bufsize>"
	echo "        ./test-consistency.sh <file> <key>"
	echo "        ./test-consistency.sh <file>"
	echo ""
	echo "        <algo> in {aes-128-ecb,aes-192-ecb,aes-256-ecb,bf-ecb,camellia-128-ecb,cast-ecb,des-ecb,idea-ecb} or"
	echo "        <algo> = all"
	exit 0
fi

KEY="A10101F10101F1F1"
# KEY="0"
if [[ -n $2 ]]; then
	KEY=$2;
fi

make -s -j5 -C ..

rm -f consistency.log

if [[ -n $3 ]]; then
	if [[ $3 == "auto" ]]; then
		BUFSIZE=`ls -l $1|awk {'print $5'}`
	else
		BUFSIZE=$3;
	fi
fi

if [[ $2 == "sample.in" && ! -e sample.in ]]; then;
	echo "Creating a 100 MB sample.in file..."
	dd bs=1048576 count=100 if=/dev/urandom of=sample.in
fi

for cipher in $ENC_CIPHERS; do
    rm -f $cipher.out.cuda $cipher.out.cpu $cipher.cuda.enc $cipher.cpu.enc $cipher.out.cpu.cuda
	echo "\n==== $cipher ENCRYPTION tests ===="
	echo ">> CUDA encryption" 1>> consistency.log 2>> consistency.log
	echo "---------------" 1>> consistency.log 2>> consistency.log
	time $OPENSSL enc -engine cudamrg -e -$cipher -nosalt -v -in $1 -out $cipher.cuda.enc -bufsize $BUFSIZE -K "$KEY" -iv "$IV" 1>> consistency.log 2>> consistency.log
	echo -e "\n>> CPU encryption" 1>> consistency.log 2>> consistency.log
	echo "--------------" 1>> consistency.log 2>> consistency.log
	time $OPENSSL enc -e -$cipher -nosalt -v -in $1 -out $cipher.cpu.enc -K "$KEY" -iv $IV 1>> consistency.log 2>> consistency.log

	echo "\n==== $cipher DECRYPTION tests ===="
	echo ">> CUDA decryption" 1>> consistency.log 2>> consistency.log
	echo "---------------" 1>> consistency.log 2>> consistency.log
	time $OPENSSL enc -engine cudamrg -d -$cipher -nosalt -v -in $cipher.cuda.enc -out $cipher.out.cuda -bufsize $BUFSIZE -K "$KEY" -iv "$IV" 1>> consistency.log 2>> consistency.log
	time $OPENSSL enc -engine cudamrg -d -$cipher -nosalt -v -in $cipher.cpu.enc -out $cipher.out.cpu.cuda -bufsize $BUFSIZE -K "$KEY" -iv "$IV" 1>> consistency.log 2>> consistency.log
	# echo -e "\n>> CPU decryption" 1>> consistency.log 2>> consistency.log
	# echo "--------------" 1>> consistency.log 2>> consistency.log
	# time $OPENSSL enc -d -$cipher -nosalt -v -in $cipher.cpu.enc -out $cipher.out.cpu -K "$KEY" -iv "$IV" 1>> consistency.log 2>> consistency.log

    if [[ `diff $1 $cipher.out.cuda` ]]; then
        cat consistency.log
		echo ">> FAIL: files differ!"
		echo ">> XXD $1:"
		xxd $1|head -n 5
		echo ">> XXD $cipher.out.cuda:"
		xxd $cipher.out.cuda|head -n 5
		echo ">> XXD $cipher.cuda.enc:"
		xxd $cipher.cuda.enc|head -n 5
		echo ">> XXD $cipher.cpu.enc:"
		xxd $cipher.cpu.enc|head -n 5
		echo ">> XXD $cipher.out.cpu.cuda:"
		xxd $cipher.out.cpu.cuda|head -n 5
	else
		echo ">> files match"
		rm -rf $cipher.out.cuda $cipher.out.cpu $cipher.cuda.enc $cipher.cpu.enc $cipher.out.cpu.cuda
        rm consistency.log
	fi

done

