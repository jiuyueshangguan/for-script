ips=10.0.104
> /tmp/tong.txt
> /tmp/butong.txt
for i in `seq 1 154`
do
{
  ping -c2 $ips.$i
  if [ $? -eq 0 ];then
      echo $ips.$i >> /tmp/tong.txt
  else
      echo $ips.$i >> /tmp/butong.txt
  fi
}&
done
