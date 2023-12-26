#!/bin/bash
# shellcheck disable=SC1091

function set_DRACUT () {
    # Get the config paths
    source "$SCRIPTDIR/lib/paths.sh"

    # Write the dracut config
    echo "add_drivers+=\" vfio_pci vfio vfio_iommu_type1 vfio_virqfd \"" > "$SCRIPTDIR/$DRACUT/10-vfio.conf"

    # Get the kernel_args file content
    CMDLINE=$(cat "$SCRIPTDIR/config/kernel_args")

    # Update kernel_args to load the vfio_pci module early in dracut (as dracut uses kernel arguments for early loading)
    echo "$CMDLINE rd.driver.pre=vfio_pci" > "$SCRIPTDIR/config/kernel_args"

    # Bind GPU to VFIO
    "$SCRIPTDIR/lib/set_VFIO.sh" "$1"

    # Configure modprobe
    exec "$SCRIPTDIR/lib/set_MODPROBE.sh" "$1"
}

function main () {
    SCRIPTDIR=$(dirname "$(realpath "$0")" | perl -pe "s/\/\.\.\/lib//" | perl -pe "s/\/lib$//")

    set_DRACUT "$1"
}

main "$1"