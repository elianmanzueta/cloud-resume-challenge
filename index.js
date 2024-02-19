const counter = document.querySelector(".counter");

async function updateCounter() {
    let response = await fetch("https://qdmoubt7xmhvyfbjw3gb6t5p740ojjfl.lambda-url.us-east-2.on.aws/");
    let data = await response.json();
    counter.innerHTML = `This site has been visited ${data} times!`;
}

updateCounter();