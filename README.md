# Customer-Segmentation-and-RFM-Analysis-Project
This MySQL project analyzes a marketing campaign dataset using RFM analysis. It creates a database, calculates RFM scores, and establishes customer segments. The resulting insights aid in tailoring marketing strategies based on customer behavior and value, optimizing engagement and targeting.

# Project Structure
**Database Setup:**

The project begins with setting up a MySQL database named RFM_analysis and creating a table named marketing_campaign to store customer data.
1. **Exploratory Data Analysis (EDA):**
Initial exploration includes fetching the head of the dataset, checking the dataset's shape, data types, and identifying missing values and duplicates.
2. **Data Cleaning:**
Missing values are examined, and duplicated rows are identified. Columns related to product purchases are renamed for clarity.
3. **Feature Engineering:**
New columns for 'Frequency' and 'Monetary' are added to the dataset, and values are calculated based on specified formulas.
4. **Creating RFM Data:**
A new table named rfm_dataset is created with 'ID' as the index, containing columns for 'Recency,' 'Frequency,' and 'Monetary.'
5. **RFM Score Calculation:**
RFM scores are calculated for each customer based on their recency, frequency, and monetary values.
6. **RFM View Creation:**
A view named RFM_View is created to display detailed information about each customer, including RFM scores and an average RFM score.
7. **Customer Segmentation:**
A view named CustomerSegmentation is created to segment customers based on their average RFM scores into categories such as 'High Value,' 'Mid Value,' and 'Low Value.' Additional customer segments are created, such as 'VIP,' 'Regular,' 'Dormant,' 'Churned,' and 'New Customer.'
8.**Analysis and Insights:**
The project concludes with a comprehensive analysis of customer segments, providing insights into customer distribution across value segments and customer behavior.
# Conclusion
This project provides a structured approach to customer segmentation and RFM analysis, enabling businesses to tailor their marketing strategies based on customer behavior and value. The insights gained from this analysis can contribute to more effective and targeted marketing campaigns.
