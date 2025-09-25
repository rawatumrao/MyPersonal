	
    	 // Scroll to active folder after jsTree loads and selects node
        $('#folderTree').on('ready.jstree', function () {
          setTimeout(function() {
            scrollToSelectedFolder();
          }, 500); // Increased delay for better reliability
        });

    	
    	// Function to scroll to the selected folder in the tree
    	function scrollToSelectedFolder() {
    	    // Try multiple selectors to find the active/selected node
    	    let activeNode = document.querySelector('.jstree-clicked') || 
    	                    document.querySelector('.jstree-selected > a') ||
    	                    document.querySelector('#folderTree .jstree-anchor[aria-selected="true"]');
    	    
    	    if (activeNode) {
    	        const $folderTreeContainer = $('#ft'); // The scrollable container
    	        const $activeNode = $(activeNode);
    	        
    	        // Calculate positions
    	        const containerTop = $folderTreeContainer.offset().top;
    	        const containerHeight = $folderTreeContainer.height();
    	        const nodeTop = $activeNode.offset().top;
    	        const nodeHeight = $activeNode.outerHeight();
    	        const currentScrollTop = $folderTreeContainer.scrollTop();
    	        
    	        // Calculate the node's position relative to the container
    	        const nodeRelativeTop = nodeTop - containerTop + currentScrollTop;
    	        
    	        // Calculate the desired scroll position to center the node
    	        const targetScrollTop = nodeRelativeTop - (containerHeight / 2) + (nodeHeight / 2);
    	        
    	        // Only scroll if the node is not already visible
    	        const isVisible = nodeTop >= containerTop && 
    	                         (nodeTop + nodeHeight) <= (containerTop + containerHeight);
    	        
    	        if (!isVisible) {
    	            $folderTreeContainer.animate({ 
    	                scrollTop: Math.max(0, targetScrollTop) 
    	            }, 500);
    	        }
    	        
    	        // Optional: Add a subtle highlight effect
    	        $activeNode.addClass('scroll-highlight');
    	        setTimeout(() => {
    	            $activeNode.removeClass('scroll-highlight');
    	        }, 2000);
    	    }
    	}
