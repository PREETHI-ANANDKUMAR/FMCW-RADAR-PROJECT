# FMCW Radar for Short-Range Target Detection

## 📡 Project Overview

This project focuses on the design and implementation of a Frequency Modulated Continuous Wave (FMCW) radar system for short-range target detection and range estimation.

The system generates an FMCW chirp signal, introduces a time delay corresponding to a target, and mixes the transmitted and received signals to obtain a beat signal. The beat frequency is extracted using FFT-based signal processing in GNU Octave and is used to estimate the target range.

The project can also be extended to detect moving targets by analyzing the Doppler frequency shift produced by target motion.

## 🎯 Objectives

- Generate FMCW radar signals.
- Model target reflections using different time delays.
- Extract beat frequency using FFT.
- Estimate target range from beat frequency.
- Study the relationship between delay and beat frequency.
- Analyze Doppler shift for moving targets.
- Develop a foundation for range-Doppler processing.
- 
## ⚙️ System Architecture

The overall signal-processing flow is:

**FMCW Signal Generation**  
↓  
**Target / Time Delay**  
↓  
**Received Signal**  
↓  
**Signal Mixing / De-chirping**  
↓  
**Beat Signal**  
↓  
**FFT Processing**  
↓  
**Beat Frequency Extraction**  
↓  
**Range Estimation**

---

## 🔲 GNU Radio Flowgraph

The FMCW radar signal generation and processing are implemented using GNU Radio.

The GNU Radio flowgraphs include signal generation, delay, signal mixing, and beat-signal extraction.

The flowgraph images are available in the 'BLOCK DIAGRAM' folder.

The GNU Radio files are available in the 'GNU RADIO' folder.

---

## 💻 GNU Octave Signal Processing

GNU Octave is used to process the beat signal obtained from GNU Radio.

The processing includes:

1. Reading binary signal data.
2. Converting the samples into complex samples.
3. Performing FFT.
4. Identifying the dominant beat-frequency component.
5. Estimating target range from the beat frequency.

The Octave source codes are available in the 'GNU OCTAVE' folder.

## 📐 Range Estimation

For FMCW radar, the beat frequency is related to the propagation delay of the reflected signal.

The target range can be estimated from the measured beat frequency and the FMCW chirp slope.

The basic relationship is:

**R = (c × f_b) / (2 × S)**

where:

- **R** = target range
- **c** = speed of light
- **f_b** = beat frequency
- **S** = chirp slope

The chirp slope is determined from the bandwidth and chirp duration.

---

## 🚗 Moving Target and Doppler Shift

For a stationary target, the measured beat frequency is primarily related to the target's range.

When the target is moving, its motion introduces an additional Doppler frequency shift.

Therefore, FMCW radar can be extended to estimate both:

- Target range
- Target velocity

By processing multiple chirps, Doppler information can be extracted and used to generate a range-Doppler map.

---

## 📊 Experimental Analysis

Different delay values are used to study the relationship between target delay and beat frequency.

The generated radar data is stored and processed using GNU Octave.

The project investigates how the beat frequency changes with different simulated target delays and how this information can be used for range estimation.

---

## 📁 Project Structure

```text
FMCW-RADAR-PROJECT
│
├── BLOCK DIAGRAM
│   └── FMCW radar and GNU Radio flowgraph images
│
├── DATA
│   └── Sample radar signal data
│
├── DOCUMENTATION
│   └── Project documentation and reports
│
├── GNU OCTAVE
│   └── Signal processing and range estimation codes
│
├── GNU RADIO
│   └── GNU Radio flowgraph files
│
├── .gitignore
└── README.md
