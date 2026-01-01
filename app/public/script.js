// Define to fetch random quote and author.
async function loadQuote() {
    const response = await fetch('/api/random-text');
    const data = await response.json();
    document.getElementById('quote').innerText = data.text;
    document.getElementById('author').innerText = data.author;
}

// Call the function.
loadQuote();
