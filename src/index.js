const counter = document.querySelector(".counter");


async function updateCounter() {
    /* Sends a request to the Lambda function URL */
    let response = await fetch("https://mgkjnpk3gqqcnf46dfwe3gxz4q0sweke.lambda-url.us-east-2.on.aws/");
    let data = await response.json();
    counter.innerHTML = `This site has been visited ${data} times!`;
}

updateCounter();