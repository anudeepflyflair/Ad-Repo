import json
import pandas as pd
import boto3
import os
from io import BytesIO

# Initialize S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Define your source and target S3 bucket names from environment variables
    source_bucket = os.environ['SOURCE_BUCKET']
    target_bucket = os.environ['TARGET_BUCKET']
    target_key = os.environ['TARGET_KEY']  # Path where you want to save the Excel file

    # List to hold DataFrames for each JSON file
    dataframes = []

    # List all objects in the source bucket
    response = s3_client.list_objects_v2(Bucket=source_bucket)

    # Check if the response contains any objects
    if 'Contents' in response:
        for obj in response['Contents']:
            # Get the object key
            key = obj['Key']

            # Check if the file is a JSON file
            if key.endswith('.json'):
                print(f"Processing file: {key}")
               
                # Read JSON file from S3
                json_response = s3_client.get_object(Bucket=source_bucket, Key=key)
                json_data = json.loads(json_response['Body'].read().decode('utf-8'))

                # Extract the necessary fields
                booking_data = json_data['data']['booking']
                reference = booking_data['reference']
                number_of_passengers = booking_data['number_of_passengers']
                route_type = booking_data['route_type']

                # Create a DataFrame with the extracted data
                data = {
                    'Reference': [reference],
                    'Number of Passengers': [number_of_passengers],
                    'Route Type': [route_type]
                }
                df = pd.DataFrame(data)

                # Append the DataFrame to the list
                dataframes.append(df)

    # Combine all DataFrames into a single DataFrame
    if dataframes:
        combined_df = pd.concat(dataframes, ignore_index=True)

        # Save the DataFrame to an Excel file in memory
        excel_buffer = BytesIO()
        combined_df.to_excel(excel_buffer, index=False, engine='openpyxl')
        excel_buffer.seek(0)  # Move to the beginning of the BytesIO buffer

        # Upload the Excel file to the target S3 bucket
        s3_client.put_object(Bucket=target_bucket, Key=target_key, Body=excel_buffer.getvalue())

        print("Excel file has been uploaded to S3 successfully.")
    else:
        print("No JSON files found in the source bucket.")

    return {
        'statusCode': 200,
        'body': json.dumps('Process completed successfully.')
    }
