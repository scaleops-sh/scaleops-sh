#!/bin/bash
set -e

# Defaults
NAMESPACE=""
WORKLOAD=""
WORKLOAD_TYPE=""
RECOMMENDATION_NAME=""
ALL_WORKLOADS=false
ALL_NAMESPACES=false
DRY_RUN=false
KIND="recommendations.analysis.scaleops.sh"

# Allowed workload types
allowed_types=(deployment statefulset daemonset replicaset deploymentconfig replicationcontroller)

print_help() {
  cat <<EOF
Usage: $0 [options]

Options:
  --namespace, -n <namespace>         Target namespace
  --workload, -w <name>               Workload name (suffix for Recommendation)
  --workload-type, -t <type>          Prefix for workload name:
                                       allowed: ${allowed_types[*]}, rollout
  --recommendation-name, -r <name>    Use exact Recommendation name
  --all                                Patch all Recommendations in the namespace (or across all namespaces with -A)
  --all-namespaces, -A                Also apply --all across all namespaces
  --dry-run                           Print commands without executing
  --help                              Show this help message

Examples:
  $0 -n my-ns -w cpu-demo -t deployment
  $0 -n my-ns -r spark-worker-6a44366740
  $0 -n my-ns --all --dry-run
  $0 --all --all-namespaces
EOF
}

# Helper: is $1 in allowed_types?
is_allowed() {
  for t in "${allowed_types[@]}"; do
    [[ "$t" == "$1" ]] && return 0
  done
  return 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --namespace|-n)        NAMESPACE="$2"; shift 2 ;;
    --workload|-w)         WORKLOAD="$2"; shift 2 ;;
    --workload-type|-t)    WORKLOAD_TYPE="$2"; shift 2 ;;
    --recommendation-name|-r) RECOMMENDATION_NAME="$2"; shift 2 ;;
    --all)                 ALL_WORKLOADS=true; shift ;;
    --all-namespaces|-A)   ALL_NAMESPACES=true; shift ;;
    --dry-run)             DRY_RUN=true; shift ;;
    --help)                print_help; exit 0 ;;
    *) echo "❌ Unknown option: $1"; print_help; exit 1 ;;
  esac
done

# Validate incompatible flags
if [[ -n "$RECOMMENDATION_NAME" && ( -n "$WORKLOAD" || "$ALL_WORKLOADS" == true ) ]]; then
  echo "❌ Cannot combine --recommendation-name with --workload or --all."
  exit 1
fi
if [[ -z "$RECOMMENDATION_NAME" && -z "$WORKLOAD" && "$ALL_WORKLOADS" != true ]]; then
  echo "❌ Provide --recommendation-name, or --workload + [--workload-type], or --all."
  exit 1
fi
if [[ "$ALL_NAMESPACES" == false && -z "$NAMESPACE" ]]; then
  echo "❌ Specify --namespace, or use --all-namespaces (-A) with --all."
  exit 1
fi

# Validate workload-type if given (only when using --workload)
if [[ -n "$WORKLOAD" && -n "$WORKLOAD_TYPE" ]]; then
  if [[ "$WORKLOAD_TYPE" != "rollout" ]] && ! is_allowed "$WORKLOAD_TYPE"; then
    echo "❌ For customOwnerGrouping types, use --recommendation-name with the recommendation resource name, instead of --workload and --workload-type."
    exit 1
  fi
fi

# Build target list
targets=()
if [[ -n "$RECOMMENDATION_NAME" ]]; then
  targets+=( "${NAMESPACE};${RECOMMENDATION_NAME}" )
elif [[ -n "$WORKLOAD" ]]; then
  # Construct Recommendation name
  if [[ -n "$WORKLOAD_TYPE" ]]; then
    prefix=$([[ "$WORKLOAD_TYPE" == "rollout" ]] && echo "family-scaleops-rollout" || echo "$WORKLOAD_TYPE")
    full_name="${prefix}-${WORKLOAD}"
  else
    full_name="$WORKLOAD"
  fi
  targets+=( "${NAMESPACE};${full_name}" )
else
  # --all case
  if [[ "$ALL_NAMESPACES" == true ]]; then
    while IFS=";" read -r ns name; do
      targets+=( "${ns};${name}" )
    done < <(kubectl get $KIND -A -o jsonpath='{range .items[*]}{.metadata.namespace}{";"}{.metadata.name}{"\n"}{end}')
  else
    while IFS=";" read -r ns name; do
      targets+=( "${ns};${name}" )
    done < <(kubectl get $KIND -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.namespace}{";"}{.metadata.name}{"\n"}{end}')
  fi
fi

# Patch each target
for entry in "${targets[@]}"; do
  ns="${entry%;*}"
  name="${entry#*;}"
  cmd="kubectl patch $KIND \"$name\" -n \"$ns\" --type=merge -p '{\"spec\":{\"Automation\":{\"automatedBy\":null, \"attachPolicyBy\":null}}}'"

  echo "🔧 Target: $KIND/$name in namespace $ns"
  if [[ "$DRY_RUN" == true ]]; then
    echo "➡️ Dry-run: $cmd"
  else
    if ! output=$(eval $cmd 2>&1); then
      echo "⚠️ Error patching $KIND/$name in $ns:"
      echo "$output"
    fi
  fi
done
