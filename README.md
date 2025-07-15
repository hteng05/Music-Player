# Music Player – Custom Ruby Program

This project is a custom-designed **music player application** built with **Ruby** and the **Gosu** library. It was developed as a final project for **COS10009 – Introduction to Programming (2024, Semester 1)** at Swinburne University. The project was independently implemented and awarded a **High Distinction (HD)** for its creativity, structured logic, and interactive GUI.

---

## About the Unit

**COS10009 – Introduction to Programming** introduces core programming concepts using Ruby, Python, and C. Students learn structured programming, modular design, and interactive application development through hands-on projects.

---

## Project Overview

This music player simulates a fully interactive desktop audio application. It allows users to explore albums, filter tracks by genre or year, and build playlists through a graphical interface. It was built entirely in **Ruby** using the `gosu` graphics and audio library, with custom logic for rendering, state transitions, playlist management, and mouse-based input.

---

## Features

- Graphical interface with interactive buttons and navigation
- Browse music by:
  - **All Albums**
  - **Year**
  - **Genre**
  - **Custom Playlist**
- Visual display of album cover, artist, title, year, and genre
- **Right-click** on a song to add it to the playlist
- Play, pause, skip, and navigate through tracks
- Volume control with slider
- Track playback view with track name and album info

---

## Screenshots

### Home Menu

Navigate by album, year, genre, or playlist:

![Home Screen](images/image1.png)

---

### Album/Track Listing

Displays each album with its metadata and cover art:

![Album View](images/image2.png)

---

### Playing a Track

The now-playing screen shows song details and tracklist.  
**To add a song to the playlist, right-click the song title.**

![Now Playing Screen](images/image3.png)

---

### Playlist Playback

Play through your custom playlist with skip/back/play buttons:

![Playlist Screen](images/image4.png)

---

## Technologies Used

- **Language:** Ruby
- **Libraries:**  
  - [`gosu`](https://www.libgosu.org/) – 2D rendering and audio playback  
  - `rubygems` – for dependency management
- **Concepts Applied:**  
  - Mouse event handling  
  - Object-oriented design  
  - Audio playback  
  - Scene/state transitions

---

## How to Run

### Requirements

- Ruby (2.7+)
- Gosu gem

### Installation Steps

1. Install Ruby:  
   [https://www.ruby-lang.org/en/downloads/](https://www.ruby-lang.org/en/downloads/)

2. Install Gosu:

   ```bash
   gem install gosu
   ```

3. Clone this repository:

   ```bash
   git clone https://github.com/hteng05/Music-Player.git
   cd Music-Player
   ```

4. Run the program:

   ```bash
   ruby music_player.rb
   ```

---

## Author

**Duong Ha Tien Le**  
Swinburne University of Technology  
Bachelor of Computer Science  
Unit: COS10009 – Introduction to Programming (2024)

---

## License

This project was created for academic purposes. Redistribution or reuse for commercial purposes is not permitted. All media assets used (e.g. album covers) are for demonstration only.
