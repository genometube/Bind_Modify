mkdir -p tmp_001_${1}
cov=$1
sort -k1,1 -k2,2n -k3,3n  -T tmp_001_${1} $cov| bgzip > $cov.bgz
tabix -s 1 -b 2 -e 3 $cov.bgz
rm -rf tmp_001_${1}
