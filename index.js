const counter = document.querySelector(".counter-number");
async function updateCounter() {
    let response = await fetch("https://kxi6m67c5itf47n66x63hlewke0bxjbu.lambda-url.us-east-1.on.aws/");
    let data = await response.json();
    counter.innerHTML = `This site has been visited ${data} times!`;
}