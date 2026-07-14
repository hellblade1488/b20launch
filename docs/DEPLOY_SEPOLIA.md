# Деплой B20LaunchPad на Base Sepolia через Remix

Тот же процесс, что и с прошлыми 5 контрактами — Remix + MetaMask, 5 минут.

## 0. Подготовка

- В MetaMask добавлена сеть **Base Sepolia**:
  - Network name: `Base Sepolia`
  - RPC URL: `https://sepolia.base.org`
  - Chain ID: `84532`
  - Currency: `ETH`
  - Explorer: `https://sepolia.basescan.org`
- На кошельке есть тестовый ETH на Base Sepolia. Бесплатный кран: <https://portal.cdp.coinbase.com/products/faucet> (или любой «Base Sepolia faucet»).

## 1. Remix

1. Открой <https://remix.ethereum.org>.
2. Создай файл `B20LaunchPad.sol`, вставь содержимое из `contracts/B20LaunchPad.sol` этого репозитория.
3. Вкладка **Solidity Compiler**: версия `0.8.20`+ → **Compile**. Должна быть зелёная галочка.
4. Вкладка **Deploy & Run**: Environment → **Injected Provider — MetaMask**, сеть в MetaMask — **Base Sepolia** (Chain ID 84532).
5. Contract → `B20LaunchPad` → **Deploy** → Confirm в MetaMask.
6. Скопируй адрес из «Deployed Contracts» — пришли его мне, я впишу его в сайт и README.

## 2. Верификация на BaseScan (сразу, не откладывая)

1. Открой `https://sepolia.basescan.org/address/АДРЕС` → **Contract** → **Verify and Publish**.
2. Compiler `0.8.20`, License `MIT`, Optimization — как было в Remix (по умолчанию No).
3. Вставь исходник целиком → Submit.

## 3. Быстрая проверка после деплоя

На верифицированной странице контракта в BaseScan → **Read Contract**:

- `owner` → твой адрес
- `fee` → `0`
- `FACTORY` → `0xB20f000000000000000000000000000000000000`
- `predictAddress(0, твой_адрес, 0x0000...0001)` → должен вернуть адрес вида `0xB200…` без ошибки — значит связка с фабрикой работает.
