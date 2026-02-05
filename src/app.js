function greet(name) {
    return `Hello, ${name}!`;
}
module.exports = { greet };

// Example usage:
if(require.main === module) {
    console.log(greet("World"));
}