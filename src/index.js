const counter = document.querySelector(".counter");

async function updateCounter() {
    let response = await fetch("https://mgkjnpk3gqqcnf46dfwe3gxz4q0sweke.lambda-url.us-east-2.on.aws/");
    let data = await response.json();
    counter.innerHTML = `This site has been visited ${data} times!`;
}

updateCounter();