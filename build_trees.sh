# change directory to this TreeUtils folder
cd

mkdir ./clone_trees/


for file in clone_hmids/*;

do
# where mix stores the results
mkdir ./mixtest/

clone=$(basename $file _for_tree.txt)

# run TreeUtils pipeline
java -jar TreeUtils-assembly-1.3.jar \
     --allEventsFile $file \
     --mixRunLocation ./mixtest/ \
     --outputTree ./clone_trees/${clone}.json \
     --sample ALL \
     --mixEXEC /Applications/phylip-3.695/exe/mix.app/Contents/MacOS/mix

# remove and clear mix output directory
rm -r ./mixtest/

done
