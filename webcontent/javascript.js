let rainbowColors = ['green', 'yellow', 'rebeccapurple', 'blue', 'turquoise', 'red'];

//get variables from webpage

const gridContainer = document.querySelector('#gridContainer');

const slider = document.querySelector('.slider');

let gridValue = slider.value;

const colorPicker = document.querySelector('.colorPicker');

let userColor = colorPicker.value;

const colorMode = document.querySelector('.colorMode');

const rainbowMode = document.querySelector('.rainbowMode');

const eraser = document.querySelector('.eraser')

const sliderText = document.querySelector('.sliderText');

sliderText.textContent = `${slider.value} X ${slider.value}`;

//add listeners for page load and user inputs

window.addEventListener('load', () => {
    colorMode.classList.add('selectedButton');
    gridValue = slider.value;
    makeGrid(gridValue);
    
})

slider.addEventListener('input', () => {
    sliderText.textContent = `${slider.value} X ${slider.value}`;
    
    
})

slider.addEventListener('change', () => {
    gridValue = slider.value;
    makeGrid(gridValue);
    
})

colorPicker.addEventListener('change', () =>{
    if (colorMode.classList.contains('selectedButton')) {
        userColor = colorPicker.value;
    }
    sketching(userColor);
    
})

colorMode.addEventListener('click', () => {
    eraser.classList.remove('selectedButton');
    colorMode.classList.add('selectedButton');
    rainbowMode.classList.remove('selectedButton');
    userColor = colorPicker.value;
    sketching(userColor);
})

eraser.addEventListener('click', () => {
    eraser.classList.add('selectedButton');
    colorMode.classList.remove('selectedButton');
    rainbowMode.classList.remove('selectedButton');
    userColor = 'white';
    sketching(userColor);
})

rainbowMode.addEventListener('click', () => {
    eraser.classList.remove('selectedButton');
    colorMode.classList.remove('selectedButton');
    rainbowMode.classList.add('selectedButton');
    userColor = rainbowColors[2];
    sketching(userColor);
})



//operation functions
function makeGrid(gridValue) {    
    while (gridContainer.firstChild){
    gridContainer.removeChild(gridContainer.lastChild)
    }
    for (let n=0; n<gridValue; n++) {
        const gridRow = document.createElement('div');
        gridRow.classList.add('gridRow');
        for (let i = 0; i <gridValue; i++) {
            const gridSquare = document.createElement('div');
            gridSquare.classList.add('square');
            gridRow.appendChild(gridSquare);
        };
        gridContainer.appendChild(gridRow);

    }
    sketching(userColor);
}

function sketching(userColor) {
    
    const squares = document.querySelectorAll('.square');
    squares.forEach((square) => {
        square.addEventListener('mouseenter', () => {
            if (rainbowMode.classList.contains('selectedButton')) {   //Tried to add a random selection from rainbowColors doesn't appear to work. Appears to be only selecting rainbowColors[0]
                userColor = rainbowColors[(Math.floor(Math.random()*(rainbowColors.length)))];
            }
            square.style.backgroundColor = userColor
        })
    })
    

    const clear = document.querySelector('.reset');
    clear.addEventListener('click', () => {
        squares.forEach((square) => {
            square.style.backgroundColor = 'white';
    })
})
}
