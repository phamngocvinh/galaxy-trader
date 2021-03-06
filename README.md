<h3 align="center">

[![Download][download-shield]][download-url]
[![Release][release-shield]][release-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]
</h3>

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/phamngocvinh/galaxy-trader">
    <img src="images/icon-192x192.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Galaxy Trader</h3>

  <p align="center">
    :chart: MetaTrader 5 Toolkit
    <br />
    <a href="https://github.com/phamngocvinh/galaxy-trader"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/phamngocvinh/galaxy-trader">View Demo</a>
    ·
    <a href="https://github.com/phamngocvinh/galaxy-trader/issues">Report Bug</a>
    ·
    <a href="https://github.com/phamngocvinh/galaxy-trader/issues">Request Feature</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#stars-about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#beginner-getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#build">Build</a></li>
      </ul>
    </li>
    <li><a href="#man_teacher-usage">Usage</a></li>
    <li><a href="#world_map-roadmap">Roadmap</a></li>
    <li><a href="#rocket-contributing">Contributing</a></li>
    <li><a href="#closed_book-license">License</a></li>
    <li><a href="#mailbox-contact">Contact</a></li>
    <li><a href="#books-acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## :stars: About The Project

Galaxy Trader use Ichimoku in multiple timeframe setting to find Bullish or Bearish trend.

User can set which Timeframe to check for Entry and TakeProfit.

### Built With

* [MetaEditor](https://www.metatrader5.com/en/automated-trading/metaeditor)

<!-- GETTING STARTED -->
## :beginner: Getting Started

<!-- Installation -->
### Installation

1. Download the [latest version](https://github.com/phamngocvinh/galaxy-trader/releases/latest)
2. Run with `MetaTrader 5`

<!-- Build -->
### Build

To get a local copy up and running follow these simple steps.

1. Clone the repo
   ```sh
   git clone https://github.com/phamngocvinh/galaxy-trader.git
   ```
2. Open `GalaxyTrader.mqproj` with MetaEditor

<!-- Usage -->
## :man_teacher: Usage
### - Entry Timeframe
Entry Timeframe will be used to check for Trend Entry

Entry Timeframe can be set up to 3 difference timeframes

Ex: Find Entry in M30, H1, H4 timeframe 

### - TakeProfit Timeframe
TakeProfit Timeframe will be used to check for Trend Exit (where you should take profit)

TakeProfit Timeframe can be set up to 3 difference timeframes

Ex: Check for exit in M15, M30, H1 timeframe

### - Range between Price and Cloud
This option is used to check if price has gone too far from the cloud (to avoid checking)

Ex: Only check for entry when Pip between Price and Cloud is 100 Pips

### - Checker Interval
How many `seconds` the app should check for Entry and TakeProfit

<!-- ROADMAP -->
## :world_map: Roadmap

See the [open issues](https://github.com/phamngocvinh/galaxy-trader/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->
## :rocket: Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->
## :closed_book: License

Distributed under the GPL-3.0 License. See `LICENSE` for more information.

<!-- CONTACT -->
## :mailbox: Contact

[![Mail][mail-shield]][mail-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

Project Link: [https://github.com/phamngocvinh/galaxy-trader](https://github.com/phamngocvinh/galaxy-trader)

<!-- ACKNOWLEDGEMENTS -->
## :books: Acknowledgements

* [MetaTrader 5 & MetaEditor](https://www.metatrader5.com)
* [Shields.io](https://shields.io)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[download-shield]: https://img.shields.io/github/downloads/phamngocvinh/galaxy-trader/total?style=for-the-badge&labelColor=4c566a&color=5e81ac&logo=github&logoColor=white
[download-url]: https://github.com/phamngocvinh/galaxy-trader/releases/latest
[release-shield]: https://img.shields.io/github/v/release/phamngocvinh/galaxy-trader?style=for-the-badge&labelColor=4c566a&color=5e81ac&logo=Battle.net&logoColor=white
[release-url]: https://github.com/phamngocvinh/galaxy-trader/releases/latest
[issues-shield]: https://img.shields.io/github/issues/phamngocvinh/galaxy-trader?style=for-the-badge&labelColor=4c566a&color=5e81ac&logo=Todoist&logoColor=white
[issues-url]: https://github.com/phamngocvinh/galaxy-trader/issues
[license-shield]: https://img.shields.io/github/license/phamngocvinh/galaxy-trader?style=for-the-badge&labelColor=4c566a&color=5e81ac&logo=AdGuard&logoColor=white
[license-url]: https://github.com/phamngocvinh/galaxy-trader/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/linkedin-blue?style=for-the-badge&logo=linkedin
[linkedin-url]: https://www.linkedin.com/in/phamngocvinh932
[mail-shield]: https://img.shields.io/badge/Gmail-white?style=for-the-badge&logo=gmail
[mail-url]: mailto:phamngocvinh@live.com
