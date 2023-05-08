SUSPEND_MODE=$(</tmp/suspend_mode)

# set all suspend mode that registered
all_mode=("work" "home")
indexes=( "${!all_mode[@]}")
lastIndex=${indexes[-1]}

# find current index
for i in "${!all_mode[@]}"; do
  if [[ "${all_mode[$i]}" = $SUSPEND_MODE ]]; then
    current_index=$i
  fi
done
# add one to new index
new_index=$(($current_index + 1))

if [ $new_index -gt $lastIndex ]; then
  # cycle back to the first mode
  new_index=0
fi

# write the new mode
echo ${all_mode[$new_index]} > /tmp/suspend_mode

notify-send -u critical -t 3000 "Suspend Mode" "Suspend mode changed to ${all_mode[$new_index]}"
