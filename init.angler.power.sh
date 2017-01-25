#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

################################################################################

# configure governor settings for little cluster
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay 20000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 95
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 1248000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "70 460000:85 1248000:90"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 40000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis 80000
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 384000

# configure governor settings for big cluster
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 99
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 960000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "80 960000:85 1248000:95"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis 80000
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 384000

# input boost configuration
write /sys/module/cpu_boost/parameters/input_boost_enabled 1
write /sys/module/cpu_boost/parameters/input_boost_freq "0:960000 1:960000 2:0 3:0 4:960000 5:960000 6:0 7:0"
write /sys/module/cpu_boost/parameters/input_boost_ms 40

# Setting B.L scheduler parameters
write /proc/sys/kernel/sched_migration_fixup 1
write /proc/sys/kernel/sched_upmigrate 95
write /proc/sys/kernel/sched_downmigrate 85
write /proc/sys/kernel/sched_freq_inc_notify 400000
write /proc/sys/kernel/sched_freq_dec_notify 400000

# make sure thermal is set
write /sys/module/msm_thermal/core_control/enabled 0
restorecon -R /sys/module/msm_thermal
chmod 0664 /sys/module/msm_thermal/parameters/enabled
write /sys/module/msm_thermal/parameters/enabled Y
write /sys/module/msm_thermal/parameters/limit_temp_degC 68

# android background processes are set to nice 10. Never schedule these on the a57s.
write /proc/sys/kernel/sched_upmigrate_min_nice 9

# Disable sched_boost
write /proc/sys/kernel/sched_boost 0

# change GPU initial power level from 305MHz(level 4) to 180MHz(level 5) for power savings
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 5

#enable rps static configuration
write /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus "0f"

write /sys/class/devfreq/qcom,mincpubw.33/governor "cpufreq"

write /sys/class/devfreq/qcom,cpubw.32/governor "bw_hwmon"
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/sample_ms 10
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/io_percent 34
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/hist_memory 20
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/hyst_length 10
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/low_power_ceil_mbps 0
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/low_power_io_percent 34
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/low_power_delay 20
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/guard_band_mbps 0
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/up_scale 250
write /sys/class/devfreq/qcom,cpubw.32/bw_hwmon/idle_mbps 1600

# I/O scheduler
write /sys/block/mmcblk0/queue/read_ahead_kb 2048
write /sys/block/mmcblk0/queue/scheduler fiops

# Enable Laptop Mode
write /proc/sys/vm/laptop_mode 1

#allow CPUs to go in deeper idle state than C0
write /sys/module/lpm_levels/parameters/sleep_disabled 0

# Backlight dimmer
write /sys/module/mdss_fb/parameters/backlight_dimmer 1

# Sound settings
write /sys/kernel/sound_control/speaker_gain "30 30"
write /sys/kernel/sound_control/headphone_pa_gain "1 1"
write /sys/kernel/sound_control/mic_gain 10
write /sys/kernel/sound_control/headphone_gain "8 8"
