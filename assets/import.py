import oci
import os
import sys
import urllib
import pandas as pd
from pandas import ExcelWriter
from pandas import ExcelFile


excel_file   = sys.argv[1] if len(sys.argv) > 1 else 'muproducts.xlsx' 
os_namespace = sys.argv[2] if len(sys.argv) > 2 else 'intvravipati' 
bucket_name  = sys.argv[3] if len(sys.argv) > 3 else 'images'
base_url     = 'https://objectstorage.us-phoenix-1.oraclecloud.com'



config   = oci.config.from_file()
osClient = oci.object_storage.ObjectStorageClient(config)
uploader = oci.object_storage.UploadManager(osClient,parallel_process_count=5)

# create a pandas dataframe, and add a new column
df          =   pd.read_excel(excel_file, sheet_name='Products',encoding='utf-8')
df['OBJ']   =   ['']*len(df.index)

print("Getting Links:")
for idx, row in df.iterrows() :
    links = row['IMG']
    objs = []
    for link in links.split("\n") :
        if len(link.strip()) > 0 :
            link     = link.replace("../","")
            abs_path = os.path.abspath(link)
            response = uploader.upload_file(os_namespace, bucket_name, link, abs_path, content_type='image/jpeg')
            obj_url  = base_url+"/n/"+os_namespace+'/b/'+bucket_name+"/o/"+urllib.quote(link, safe='')
            objs.append(obj_url)
            print ("Uploaded : "+link)
    # Update the dataframe
    df.at[idx,'OBJ'] = "\n".join(objs)

# create an excel writer. disable warning about long String URls in the cells
writer = pd.ExcelWriter('products_uploaded.xlsx', engine='xlsxwriter',options={'strings_to_urls': False})
# Convert the dataframe to an XlsxWriter Excel object.
df.to_excel(writer, sheet_name='Products')
# Close the Pandas Excel writer and output the Excel file.
writer.save()

