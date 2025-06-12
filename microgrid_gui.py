# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import messagebox
import csv
from datetime import datetime
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import numpy as np

# Google Sheets
import gspread
from oauth2client.service_account import ServiceAccountCredentials

def upload_to_google_sheets(data_dict):
    try:
        scope = [
            "https://spreadsheets.google.com/feeds",
            "https://www.googleapis.com/auth/drive"
        ]
        creds = ServiceAccountCredentials.from_json_keyfile_name("credentials.json", scope)
        client = gspread.authorize(creds)
        sheet = client.open("Microgrid Logs").sheet1
        row = [
            data_dict["Date"],
            data_dict["Solar"],
            data_dict["Wind"],
            data_dict["Diesel"],
            data_dict["Battery"],
            data_dict["Load"],
            data_dict["Total_Generation"],
            data_dict["Sustainable_Ratio,"],  # Keep the comma as requested
            data_dict["Status"]
        ]
        sheet.append_row(row)
        print("✅ Data uploaded to Google Sheets successfully.")
    except Exception as e:
        print(f"❌ Failed to upload data: {e}")

def solar_input(irradiance, area, efficiency):
    return irradiance * area * (efficiency / 100)

def wind_input(air_density, rotor_area, wind_speed, efficiency):
    return 0.5 * air_density * rotor_area * (wind_speed ** 3) * (efficiency / 100)

def diesel_generator_input(fuel_rate, efficiency):
    return fuel_rate * efficiency * 10

def battery_input(capacity_kWh, charge_level_percent):
    return capacity_kWh * (charge_level_percent / 100)

def total_load(load_list):
    return sum(load_list)

def save_to_csv(data_dict):
    filename = "microgrid_results.csv"
    fieldnames = list(data_dict.keys())
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            file_exists = True
    except FileNotFoundError:
        file_exists = False

    with open(filename, 'a', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(data_dict)

def plot_results(results):
    labels = ["Solar (kW)", "Wind (kW)", "Diesel (kW)", "Load (kW)"]
    values = [
        results["Solar"] / 1000,
        results["Wind"] / 1000,
        results["Diesel"],
        results["Load"]
    ]
    plt.figure(figsize=(8, 5))
    plt.bar(labels, values, color=["orange", "skyblue", "gray", "red"])
    plt.title("Energy Sources vs Load", fontsize=14)
    plt.ylabel("Power (kW)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.show(block=False)
    plt.pause(0.1)

def plot_pie_chart(results):
    labels = []
    values = []
    if results["Solar"] > 0:
        labels.append("Solar")
        values.append(results["Solar"])
    if results["Wind"] > 0:
        labels.append("Wind")
        values.append(results["Wind"])
    if results["Diesel"] > 0:
        labels.append("Diesel")
        values.append(results["Diesel"])
    plt.figure(figsize=(6,6))
    plt.pie(values, labels=labels, autopct='%1.1f%%', startangle=140, colors=["orange", "skyblue", "gray"])
    plt.title("Energy Sources Distribution", fontsize=14)
    plt.show(block=False)
    plt.pause(0.1)

# نموذج التنبؤ بالحمل (تعلم آلي) - بيانات تدريب وهمية
X_train = np.array([
    [25, 40, 8],
    [30, 35, 12],
    [28, 30, 15],
    [22, 45, 18],
    [20, 50, 21],
    [18, 55, 23],
    [24, 38, 6]
])
y_train = np.array([150, 200, 180, 160, 140, 130, 145])  # الحمل بالكيلوواط

model = LinearRegression()
model.fit(X_train, y_train)

def predict_load(temp, humidity, hour):
    input_features = np.array([[temp, humidity, hour]])
    predicted_load = model.predict(input_features)[0]
    return predicted_load

def run_microgrid():
    try:
        irr = float(entry_irr.get())
        if irr < 0:
            raise ValueError("Irradiance cannot be negative")

        area = float(entry_area.get())
        if area <= 0:
            raise ValueError("Panel area must be greater than zero")

        solar_eff = float(entry_solar_eff.get())
        if not (0 <= solar_eff <= 100):
            raise ValueError("Solar panel efficiency must be between 0 and 100")

        solar_power = solar_input(irr, area, solar_eff)

        rho = 1.225  # Air density
        rotor = float(entry_rotor.get())
        if rotor <= 0:
            raise ValueError("Rotor area must be greater than zero")

        speed = float(entry_speed.get())
        if speed < 0:
            raise ValueError("Wind speed cannot be negative")

        wind_eff = float(entry_wind_eff.get())
        if not (0 <= wind_eff <= 100):
            raise ValueError("Wind turbine efficiency must be between 0 and 100")

        wind_power = wind_input(rho, rotor, speed, wind_eff)

        fuel_rate = float(entry_fuel.get())
        if fuel_rate < 0:
            raise ValueError("Diesel fuel rate cannot be negative")

        diesel_eff = float(entry_diesel_eff.get())
        if not (0 <= diesel_eff <= 100):
            raise ValueError("Diesel generator efficiency must be between 0 and 100")

        diesel_power = diesel_generator_input(fuel_rate, diesel_eff)

        batt_capacity = float(entry_batt_cap.get())
        if batt_capacity < 0:
            raise ValueError("Battery capacity cannot be negative")

        batt_level = float(entry_batt_level.get())
        if not (0 <= batt_level <= 100):
            raise ValueError("Battery charge level must be between 0 and 100")

        battery_energy = battery_input(batt_capacity, batt_level)

        # قراءة بيانات الطقس والوقت للتنبؤ بالحمل
        temp = float(entry_temp.get())
        humidity = float(entry_humidity.get())
        hour = float(entry_hour.get())

        predicted_load = predict_load(temp, humidity, hour)
        if predicted_load < 0:
            predicted_load = 0

        # تستخدم الحمل المتوقع بدلاً من الإدخال اليدوي
        total_demand = predicted_load

        total_generation_kW = (solar_power + wind_power) / 1000 + diesel_power

        result = (
            f"Solar Power: {solar_power:.2f} W\n"
            f"Wind Power: {wind_power:.2f} W\n"
            f"Diesel Power: {diesel_power:.2f} kW\n"
            f"Battery Energy: {battery_energy:.2f} kWh\n"
            f"Predicted Load: {predicted_load:.2f} kW\n"
            f"Total Generation: {total_generation_kW:.2f} kW\n"
        )

        if total_generation_kW >= total_demand:
            status = "Supply is sufficient"
        else:
            deficit = total_demand - total_generation_kW
            status = f"Deficit: {deficit:.2f} kW"

        max_source = max(solar_power/1000, wind_power/1000, diesel_power)
        if diesel_power == max_source:
            messagebox.showwarning("Warning", "Diesel is the highest source! Consider increasing renewable sources.")

        sustainable_power = (solar_power + wind_power) / 1000
        sustainable_ratio = (sustainable_power / total_generation_kW) * 100 if total_generation_kW > 0 else 0.0

        result += f"\nRenewable Energy Ratio: {sustainable_ratio:.2f}%\n"
        result += status
        messagebox.showinfo("Results", result)

        results = {
            "Date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "Solar": solar_power,
            "Wind": wind_power,
            "Diesel": diesel_power,
            "Battery": battery_energy,
            "Load": total_demand,
            "Total_Generation": total_generation_kW,
            "Sustainable_Ratio,": sustainable_ratio,  # comma kept as requested
            "Status": status
        }

        save_to_csv(results)
        upload_to_google_sheets(results)
        plot_results(results)
        plot_pie_chart(results)

    except Exception as e:
        messagebox.showerror("Error", f"Input error: {e}")

app = tk.Tk()
app.title("Smart Microgrid Analysis System")
app.geometry("700x720")
app.configure(bg="#f0f0f0")

fields = [
    ("Solar Irradiance (W/m²):", "irr"),
    ("Panel Area (m²):", "area"),
    ("Solar Panel Efficiency (%):", "solar_eff"),
    ("Rotor Area (m²):", "rotor"),
    ("Wind Speed (m/s):", "speed"),
    ("Wind Turbine Efficiency (%):", "wind_eff"),
    ("Diesel Fuel Rate (liters/hour):", "fuel"),
    ("Diesel Generator Efficiency (%):", "diesel_eff"),
    ("Battery Capacity (kWh):", "batt_cap"),
    ("Battery Charge Level (%):", "batt_level"),
    ("Ambient Temperature (°C):", "temp"),
    ("Humidity (%):", "humidity"),
    ("Hour of Day (0-23):", "hour")
]

entries = {}

for i, (label_text, var_name) in enumerate(fields):
    label = tk.Label(app, text=label_text, bg="#f0f0f0")
    label.grid(row=i, column=0, padx=10, pady=5, sticky="w")
    entry = tk.Entry(app, width=25)
    entry.grid(row=i, column=1, padx=10, pady=5)
    entries[var_name] = entry

entry_irr = entries["irr"]
entry_area = entries["area"]
entry_solar_eff = entries["solar_eff"]
entry_rotor = entries["rotor"]
entry_speed = entries["speed"]
entry_wind_eff = entries["wind_eff"]
entry_fuel = entries["fuel"]
entry_diesel_eff = entries["diesel_eff"]
entry_batt_cap = entries["batt_cap"]
entry_batt_level = entries["batt_level"]
entry_temp = entries["temp"]
entry_humidity = entries["humidity"]
entry_hour = entries["hour"]

btn_run = tk.Button(app, text="Run Simulation", command=run_microgrid, bg="#4CAF50", fg="white", font=("Arial", 14))
btn_run.grid(row=len(fields), column=0, columnspan=2, pady=20, ipadx=10)

app.mainloop()
