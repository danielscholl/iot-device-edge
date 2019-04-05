namespace filterModule
{
  using System;
  using System.Collections.Generic;
  using System.IO;
  using System.Runtime.InteropServices;
  using System.Runtime.Loader;
  using System.Security.Cryptography.X509Certificates;
  using System.Text;
  using System.Threading;
  using System.Threading.Tasks;
  using Microsoft.Azure.Devices.Client;
  using Microsoft.Azure.Devices.Client.Transport.Mqtt;
  using Microsoft.Azure.Devices.Shared;
  using Newtonsoft.Json;

  class Program
  {
    static int counter;
    static int windspeedThreshold { get; set; } = 12;

    class Climate
    {
      public string deviceId { get; set; }
      public double windSpeed { get; set; }
      public double humidity { get; set; }
      public long timeStamp { get; set; }
      public long Count { get; set; }
    }

    static void Main(string[] args)
    {
      Init().Wait();

      // Wait until the app unloads or is cancelled
      var cts = new CancellationTokenSource();
      AssemblyLoadContext.Default.Unloading += (ctx) => cts.Cancel();
      Console.CancelKeyPress += (sender, cpe) => cts.Cancel();
      WhenCancelled(cts.Token).Wait();
    }

    /// <summary>
    /// Handles cleanup operations when app is cancelled or unloads
    /// </summary>
    public static Task WhenCancelled(CancellationToken cancellationToken)
    {
      var tcs = new TaskCompletionSource<bool>();
      cancellationToken.Register(s => ((TaskCompletionSource<bool>)s).SetResult(true), tcs);
      return tcs.Task;
    }

    /// <summary>
    /// Initializes the ModuleClient and sets up the callback to receive
    /// messages containing temperature information
    /// </summary>
    static async Task Init()
    {
      MqttTransportSettings mqttSetting = new MqttTransportSettings(TransportType.Mqtt_Tcp_Only);
      ITransportSettings[] settings = { mqttSetting };

      // Open a connection to the Edge runtime
      ModuleClient ioTHubModuleClient = await ModuleClient.CreateFromEnvironmentAsync(settings);
      await ioTHubModuleClient.OpenAsync();
      Console.WriteLine("IoT Hub module client initialized.");

      // Read the TemperatureThreshold value from the module twin's desired properties
      var moduleTwin = await ioTHubModuleClient.GetTwinAsync();
      OnDesiredPropertiesUpdate(moduleTwin.Properties.Desired, ioTHubModuleClient);

      // Attach a callback for updates to the module twin's desired properties.
      await ioTHubModuleClient.SetDesiredPropertyUpdateCallbackAsync(OnDesiredPropertiesUpdate, null);

      // Register callback to be called when a message is received by the module
      await ioTHubModuleClient.SetInputMessageHandlerAsync("input1", FilterMessage, ioTHubModuleClient);
    }

    static Task OnDesiredPropertiesUpdate(TwinCollection desiredProperties, object userContext)
    {
      try
      {
        Console.WriteLine("Desired property change:");
        Console.WriteLine(JsonConvert.SerializeObject(desiredProperties));

        if (desiredProperties["WindSpeedThreshold"] != null)
          windspeedThreshold = desiredProperties["WindSpeedThreshold"];

      }
      catch (AggregateException ex)
      {
        foreach (Exception exception in ex.InnerExceptions)
        {
          Console.WriteLine();
          Console.WriteLine("Error when receiving desired property: {0}", exception);
        }
      }
      catch (Exception ex)
      {
        Console.WriteLine();
        Console.WriteLine("Error when receiving desired property: {0}", ex.Message);
      }
      return Task.CompletedTask;
    }

    /// <summary>
    /// This method is called whenever the module is sent a message from the EdgeHub.
    /// It just pipe the messages without any change.
    /// It prints all the incoming messages.
    /// </summary>
    static async Task<MessageResponse> FilterMessage(Message message, object userContext)
    {
      int counterValue = Interlocked.Increment(ref counter);

      try
      {
        ModuleClient moduleClient = (ModuleClient)userContext;
        var messageBytes = message.GetBytes();
        var messageString = Encoding.UTF8.GetString(messageBytes);

        // Get the message body.
        var climate = JsonConvert.DeserializeObject<Climate>(messageString);

        if (climate != null && climate.windSpeed > windspeedThreshold)
        {
          Console.WriteLine($"Received message {counterValue}: {messageString}");
          var filteredMessage = new Message(messageBytes);
          foreach (KeyValuePair<string, string> prop in message.Properties)
          {
            filteredMessage.Properties.Add(prop.Key, prop.Value);
          }

          filteredMessage.Properties.Add("MessageType", "Alert");
          await moduleClient.SendEventAsync("output1", filteredMessage);
        }

        // Indicate that the message treatment is completed.
        return MessageResponse.Completed;
      }
      catch (AggregateException ex)
      {
        foreach (Exception exception in ex.InnerExceptions)
        {
          Console.WriteLine();
          Console.WriteLine("Error in sample: {0}", exception);
        }
        // Indicate that the message treatment is not completed.
        var moduleClient = (ModuleClient)userContext;
        return MessageResponse.Abandoned;
      }
      catch (Exception ex)
      {
        Console.WriteLine();
        Console.WriteLine("Error in sample: {0}", ex.Message);
        // Indicate that the message treatment is not completed.
        ModuleClient moduleClient = (ModuleClient)userContext;
        return MessageResponse.Abandoned;
      }
    }
  }
}
