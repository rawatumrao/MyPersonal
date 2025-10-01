// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
        <App />
    </React.StrictMode>
);



	//Ultra-aggressive protection for totalSimultaneousEventsTxt
		var protectedField = $('#totalSimultaneousEventsTxt');
		var storedValue = '';
		var isUserInput = false;
		
		protectedField
			.attr('autocomplete','nope')
			.prop('autocomplete','nope')
			.removeAttr('name')
			.on('input keyup paste', function(e) {
				isUserInput = true;
				storedValue = $(this).val();
				setTimeout(function() { isUserInput = false; }, 100);
			})
			.on('focus', function(e) {
				storedValue = $(this).val();
				$(this).removeAttr('readonly');
			})
			.on('blur', function(e) {
				storedValue = $(this).val();
			});
		
		// Aggressive value protection with mutation observer
		var observer = new MutationObserver(function(mutations) {
			mutations.forEach(function(mutation) {
				if (mutation.type === 'attributes' && mutation.attributeName === 'value') {
					var currentVal = protectedField.val();
					if (!isUserInput && storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http'))) {
						protectedField.val(storedValue);
					}
				}
			});
		});
		
		if (protectedField.length > 0) {
			observer.observe(protectedField[0], { attributes: true, attributeFilter: ['value'] });
		}
		
		// Additional protection via intervals
		setInterval(function() {
			if (!isUserInput && protectedField.length > 0) {
				var currentVal = protectedField.val();
				if (storedValue && currentVal !== storedValue && (currentVal.includes('@') || currentVal.includes('http') || currentVal.toLowerCase().includes('user'))) {
					protectedField.val(storedValue);
				}
			}
		}, 500);
