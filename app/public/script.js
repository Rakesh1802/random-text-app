async function loadQuote() {
    const response = await fetch('/api/random-text');
    const data = await response.json();
    document.getElementById('quote').innerText = data.text;
}

loadQuote();
