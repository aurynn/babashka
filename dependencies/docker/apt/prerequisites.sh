docker.prerequisites.skopeo() {
  case `lsb_release -cs` in
    focal)
      local ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      # This is a giant hack because there's no 20.04 repository
      # and I hate this _so_ much
      # It's always the latest, because it has to be
      $__babashka_sudo /usr/bin/docker pull -q quay.io/skopeo/stable:latest
      system.file /usr/bin/skopeo \
        -s ${ABSOLUTE_PATH}/files/ubuntu/focal/usr/bin/skopeo \
        -o root \
        -g root \
        -m 0755
      ;;
    *)
      # In 20.10 and up, this will just work
      system.package skopeo
      ;;

  esac
}
