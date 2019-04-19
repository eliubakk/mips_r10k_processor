for p in lsof +d . | grep "simv" | awk {'print $2'}
do
	echo $p	
done
