echo "flatten Bullet"
npx hardhat flatten ./contracts/Bullet.sol > .temp-flat/Bullet.sol

echo "flatten GNFT"
npx hardhat flatten ./contracts/GNFT.sol > .temp-flat/GNFT.sol