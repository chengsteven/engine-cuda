#!/usr/bin/env zsh
# vim:ft=sh

ENC_CIPHERS=(aes-128-ecb aes-192-ecb aes-256-ecb)
DEC_CIPHERS=(aes-128-ecb aes-192-ecb aes-256-ecb aes-128-cbc aes-192-cbc aes-256-cbc)
#DEC_CIPHERS=(camellia-128-cbc des-cbc bf-cbc aes-128-cbc)
#DEC_CIPHERS=(camellia-128-cbc)

IV="FFFF"
BUFSIZE=8388608
OPENSSL=$HOME/local/bin/openssl
# TODO: Use getopt or zparseopts

if [[ $ARGC -le 1 ]]; then
	echo " Usage: ./test.sh {enc,dec} <file> <key> <bufsize>"
	echo "        ./test.sh {enc,dec} <file> <key>"
	echo "        ./test.sh {enc,dec} <file>"
	echo ""
	echo "        <algo> in {aes-128-ecb,aes-192-ecb,aes-256-ecb,bf-ecb,camellia-128-ecb,cast-ecb,des-ecb,idea-ecb} or"
	echo "        <algo> = all"
	exit 0
fi

KEY="A10101F10101F1F1"
if [[ -n $3 ]]; then
	KEY=$3;
fi

make -s -j5 -C ..

if [[ $1 == "enc" ]]; then
	DEC_CIPHERS=();
elif [[ $1 == "dec" ]]; then
	ENC_CIPHERS=();
fi

if [[ -n $4 ]]; then
	if [[ $4 == "auto" ]]; then
		BUFSIZE=`ls -l $2|awk {'print $5'}`
	else
		BUFSIZE=$4;
	fi
fi

if [[ $2 == "sample.in" && ! -e sample.in ]]; then;
	echo "Creating a 100 MB sample.in file..."
	dd bs=1048576 count=100 if=/dev/urandom of=sample.in
fi

for cipher in $ENC_CIPHERS; do
	echo "\n==== $cipher ENCRYPTION tests ===="
	echo ">> CUDA encryption" 1>> correctness.log 2>> correctness.log
	echo "---------------" 1>> correctness.log 2>> correctness.log
	time $OPENSSL enc -engine cudamrg -e -$cipher -nosalt -v -in $2 -out $cipher.out.cuda -bufsize $BUFSIZE -K "$KEY" 1>> correctness.log 2>> correctness.log
	echo -e "\n>> CPU encryption" 1>> correctness.log 2>> correctness.log
	echo "--------------" 1>> correctness.log 2>> correctness.log
	time $OPENSSL enc -e -$cipher -nosalt -v -in $2 -out $cipher.out.cpu -K "$KEY" 1>> correctness.log 2>> correctness.log

	CHKCPU=`cksum $cipher.out.cpu|awk {'print $1'}`
	CHKCUDA=`cksum $cipher.out.cuda|awk {'print $1'}`

	echo ""
	if [[ $CHKCPU != $CHKCUDA ]]; then
		cat correctness.log
		echo ">> CAUTION: cksum mismatch!"
		echo ">> CPU: $CHKCPU; CUDA: $CHKCUDA; "
		echo ">> XXD CPU:"
		xxd $cipher.out.cpu|head -n 5
		echo ">> XXD CUDA:"
		xxd $cipher.out.cuda|head -n 5
	else
		echo ">> CKSUM matches"
		rm -rf $cipher.out.cuda $cipher.out.cpu
	fi
	rm correctness.log
done

for cipher in $DEC_CIPHERS; do
	echo "\n==== $cipher DECRYPTION tests ===="
	echo -e "\n>> CPU encryption" 1>> correctness.log 2>> correctness.log
	echo "--------------" 1>> correctness.log 2>> correctness.log
	time $OPENSSL enc -e -$cipher -nosalt -v -in $2 -out $cipher.enc -K "$KEY" -iv "$IV" 1>> correctness.log 2>> correctness.log
	echo ">> CUDA decryption" 1>> correctness.log 2>> correctness.log
	echo "---------------" 1>> correctness.log 2>> correctness.log
	time $OPENSSL enc -engine cudamrg -d -$cipher -nosalt -v -in $cipher.enc -out $cipher.out.cuda -bufsize $BUFSIZE -K "$KEY" -iv "$IV" 1>> correctness.log 2>> correctness.log
	echo -e "\n>> CPU decryption" 1>> correctness.log 2>> correctness.log
	echo "--------------" 1>> correctness.log 2>> correctness.log
	time $OPENSSL enc -d -$cipher -nosalt -v -in $cipher.enc -out $cipher.out.cpu -K "$KEY" -iv "$IV" 1>> correctness.log 2>> correctness.log

	CHKCPU=`cksum $cipher.out.cpu|awk {'print $1'}`
	CHKCUDA=`cksum $cipher.out.cuda|awk {'print $1'}`

	echo ""
	if [[ $CHKCPU != $CHKCUDA ]]; then
		cat correctness.log
		echo ">> CAUTION: cksum mismatch!"
		echo ">> CPU: $CHKCPU; CUDA: $CHKCUDA; "
		echo ">> Encrypted file:"
		xxd $cipher.enc|head -n 5
		echo ">> XXD CPU:"
		xxd $cipher.out.cpu|head -n 5
		echo ">> XXD CUDA:"
		xxd $cipher.out.cuda|head -n 5
	else
		echo ">> $cipher CKSUM matches"
		rm -rf $cipher.out.cuda $cipher.out.cpu $cipher.enc
	fi
	rm correctness.log
done
