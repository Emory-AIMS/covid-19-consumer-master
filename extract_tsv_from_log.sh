# map -> sort -> reduce
# explode all the interactions -> sort -> reduce interactions by id


# Fetch the last log, explode all the interactions and transform them into a TSV line by line
# Do not use cat to improve 2x efficiency
jq -r '(.[0] | keys_unsorted) as $keys | map([.[ $keys[] ]])[] | @tsv' < docker/openresty/logs/coronaviruscheck.org/postdata.log > interactions_tsv.log

# Sort the interactinos (running sort not as piped command makes it more efficient, because it estimates the size of the incoming file)
sort -nk 1 interactions_tsv.log > sorted_interactionos_tsv.log
