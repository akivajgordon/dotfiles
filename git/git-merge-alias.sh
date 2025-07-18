#!/bin/bash
# Store the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Get all local branches except dev and master
branches=$(git for-each-ref --format='%(refname:short)' refs/heads/ | grep -vE '^(dev|master)$')

# For each branch
for branch in $branches; do
    echo "Processing branch: $branch"
    
    # Try to check out the branch
    if ! git checkout "$branch" 2>/dev/null; then
        echo "Failed to checkout $branch, skipping..."
        continue
    fi
    
    # Fetch latest changes
    git fetch origin dev
    
    # Try to merge without committing
    if git merge-tree $(git merge-base HEAD origin/dev) HEAD origin/dev | grep -q "^<<<<<<< "; then
        echo "Merge conflicts detected in $branch, skipping..."
        git merge --abort 2>/dev/null
        continue
    else
        # If no conflicts, perform the actual merge
        echo "Merging dev into $branch..."
        if ! git merge origin/dev; then
            echo "Merge failed for $branch, skipping..."
            git merge --abort 2>/dev/null
            continue
        fi
    fi
    
    echo "Successfully merged dev into $branch"
done

# Return to original branch
git checkout "$current_branch"
