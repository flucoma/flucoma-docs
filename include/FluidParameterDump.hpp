/*
Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
Copyright 2017-2019 University of Huddersfield.
Licensed under the BSD-3 License.
See license.md file in the project root for full license information.
This project has received funding from the European Research Council (ERC)
under the European Union’s Horizon 2020 research and innovation programme
(grant agreement No 725899).
*/

#pragma once
#include <clients/common/FluidBaseClient.hpp>
#include <clients/common/SharedClientUtils.hpp>
#include <nlohmann/json.hpp>
#include <array>
#include <fstream>
#include <string>
#include <type_traits>
#include <utility>

/// This will produce JSON output of the params and messages for a Fluid Client
/// object Because we need to preserve the declared ordering of params (which
/// turn into arguments in some hosts), the output is JSON arrays: each array
/// element is a 2 item sub-array with the name and a JSON object that has the
/// meta-data. This then turned back into an associative structure in pyton
/// (i.e. dict(...)) This way we are gurranteed to preserve ordering

// for convenience
using json = nlohmann::json;

namespace fluid {
namespace client {

template <typename>
class SharedClientRef;

// forward decls to speed up building (a lot)
namespace dataset {
class DataSetClient;
}

namespace labelset {
class LabelSetClient;
}

template <typename>
struct ParamOffsets;

template <typename Offsets, typename P>
struct ParamOffsets<const ParameterDescriptorSet<Offsets, P>>
{
  using OffsetList = Offsets;
};

template <typename C>
struct Constraint;

template <>
struct Constraint<EnumT::EnumConstraint>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const EnumT::EnumConstraint&, Tuple&)
  {
    return {"Enum", true};
  }
};

template <index MaxFFT>
struct Constraint<FFTParams::FFTSettingsConstraint<MaxFFT>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const FFTParams::FFTSettingsConstraint<MaxFFT>&, Tuple&)
  {
    return {"MaxFFT", MaxFFT > -1};
  }
};

template <typename C, typename AllParams>
Constraint<C> makeConstraint(C c, AllParams& p)
{
  return {c, p};
}

template <typename T>
struct Constraint<impl::MinImpl<T>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::MinImpl<T>& c, Tuple&)
  {
    return {"min", c.value};
  }
};

template <typename T>
struct Constraint<impl::MaxImpl<T>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::MaxImpl<T>& c, Tuple&)
  {
    return {"max", c.value};
  }
};

template <int... Is, typename Tuple>
std::array<const char*, sizeof...(Is)> relations(Tuple& params)
{
  return {{std::get<0>(std::get<Is>(params)).name...}};
}

template <int... Is>
struct Constraint<impl::UpperLimitImpl<Is...>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::UpperLimitImpl<Is...>&,
                                         Tuple& params)
  {
    return {"upper", relations<Offset + Is...>(params)};
  }
};

template <int... Is>
struct Constraint<impl::LowerLimitImpl<Is...>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::LowerLimitImpl<Is...>&,
                                         Tuple& params)
  {
    return {"lower", relations<Offset + Is...>(params)};
  }
};

template <int I>
struct Constraint<impl::FrameSizeUpperLimitImpl<I>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const impl::FrameSizeUpperLimitImpl<I>&, Tuple&)
  {
    return {"upper", "fftFrame"};
  }
};

template <int I>
struct Constraint<impl::FrameSizeLowerLimitImpl<I>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const impl::FrameSizeLowerLimitImpl<I>&, Tuple&)
  {
    return {"lower", "fftFrame"};
  }
};

template <int I>
struct Constraint<impl::MaxFrameSizeUpperLimitImpl<I>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const impl::MaxFrameSizeUpperLimitImpl<I>&, Tuple&)
  {
    return {"upper", "maxFFTFrame"};
  }
};

template <>
struct Constraint<Odd>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const Odd&, Tuple&)
  {
    return {"snap", "odd"};
  }
};

template <>
struct Constraint<PowerOfTwo>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const PowerOfTwo&, Tuple&)
  {
    return {"snap", "powerTwo"};
  }
};

template <>
struct Constraint<FrequencyAmpPairConstraint>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const FrequencyAmpPairConstraint&,
                                         Tuple&)
  {
    return {"FreqAmpPair", "true"};
  }
};

void to_json(json& j, const FFTParams& p)
{
  j = json::array({{"winSize", p.winSize()},
                   {"hopSize", p.hopRaw()},
                   {"fftSize", p.fftRaw()}});
}

void to_json(json& j, const FloatPairsArrayT::FloatPairsArrayType& p)
{
  j = json{{"value", p.value}};
}

template <typename T>
struct is_tuple_impl : std::false_type
{};

template <typename... Ts>
struct is_tuple_impl<std::tuple<Ts...>> : std::true_type
{};

template <typename T>
struct is_tuple : is_tuple_impl<std::decay_t<T>>
{};

template <typename A>
std::enable_if_t<is_tuple<A>::value, std::string> getArgType(A&)
{
  return "tuple";
}

template <typename A>
std::enable_if_t<std::is_integral<A>::value, std::string> getArgType(A&)
{
  return "integer";
}

template <typename A>
std::enable_if_t<std::is_floating_point<A>::value, std::string> getArgType(A&)
{
  return "float";
}

std::string getArgType(BufferT::type&) { return "buffer"; }

std::string getArgType(InputBufferT::type&) { return "buffer"; }

std::string getArgType(SharedClientRef<dataset::DataSetClient>&)
{
  return "DataSet";
}

std::string getArgType(SharedClientRef<labelset::LabelSetClient>&)
{
  return "LabelSet";
}

std::string getArgType(std::string&) { return "string"; }

template <typename T, size_t N>
std::string getArgType(FluidTensor<T, N>&)
{
  std::stringstream ss;
  T                 t{};
  ss << "list " << getArgType(t);
  return ss.str();
}

template <typename>
struct ReturnType;

template <class T>
class ParameterDump
{
  template <typename U>
  using DefaultValue = decltype(std::declval<U>().defaultValue);

  template <typename Param>
  static std::enable_if_t<isDetected<DefaultValue, Param>::value,
                          decltype(std::declval<Param>().defaultValue)>
  makeValue(Param& p)
  {
    return p.defaultValue;
  }

  template <typename Param>
  static std::enable_if_t<!isDetected<DefaultValue, Param>::value, std::string>
  makeValue(Param&)
  {
    return "none";
  }

public:
  using Params = typename T::ParamDescType;
  using Messages = typename T::MessageSetType;
  using Offsets = typename ParamOffsets<Params>::OffsetList;

  static void dump(std::string ofile, std::string prefix)
  {
    json j = dumpImpl(typename Params::IndexList(), Offsets{});
    std::ofstream(prefix + ofile + ".json") << j.dump(2) << '\n';
  }

  template <size_t... Is, size_t... Offsets>
  static json dumpImpl(std::index_sequence<Is...>,
                       std::index_sequence<Offsets...>)
  {
    Params& p = T::getParameterDescriptors();

    json j;
    j["parameters"] =
        json::array({jsonify<std::get<Is>(std::make_tuple(Offsets...))>(
            std::get<Is>(p.descriptors()), p.descriptors())...});
    j["messages"] = jsonify_messages();
    j["input_type"] = inputType();
    return j;
  }

  template <typename U>
  using NRTWrapped = typename U::RTClient;

  template <typename WrappedClient = T>
  static std::enable_if_t<!isDetected<NRTWrapped, WrappedClient>::value,
                          std::string>
  inputType()
  {
    using Client = typename T::Client;
    if (std::is_base_of<AudioIn, Client>::value) return "audio";
    if (std::is_base_of<ControlIn, Client>::value) return "control";
    if (std::is_base_of<OfflineIn, Client>::value)
      return "buffer or data client";
    return "unknown";
  }

  template <typename WrappedClient = T>
  static std::enable_if_t<isDetected<NRTWrapped, WrappedClient>::value,
                          std::string>
  inputType()
  {
    return "buffer or data client";
  }

  static std::string processorType(OfflineIn&) { return "offline"; }
  static std::string processorType(ControlIn&) { return "control"; }

  template <size_t Offset, size_t... Is, typename C, typename P>
  static json constraints(const C& constraints, std::index_sequence<Is...>,
                          P&       allParams)
  {
    json res = json::object();
    (void) std::initializer_list<int>{(
        res.push_back(
            Constraint<typename std::tuple_element<Is, C>::type>::template dump<
                Offset>(std::get<Is>(constraints), allParams)),
        0)...};
    return res;
  }

  template <size_t Offset, typename P, typename All>
  static json jsonify(P& param, All& allParams)
  {
    return jsonify_param<Offset>(std::get<0>(param), param, allParams);
  }

  static std::string getParamType(const BufferT&) { return "buffer"; }
  static std::string getParamType(const InputBufferT&) { return "buffer"; }
  static std::string getParamType(const FloatT&) { return "float"; }
  static std::string getParamType(const LongT&) { return "long"; }
  static std::string getParamType(const FloatPairsArrayT&) { return "float"; }
  static std::string getParamType(const StringT&) { return "string"; }
  static std::string getParamType(const FFTParamsT&) { return "fft"; }
  static std::string getParamType(const EnumT&) { return "enum"; }
  static std::string getParamType(const LongArrayT&) { return "long"; }

  static std::string
  getParamType(const SharedClientRef<dataset::DataSetClient>::ParamType&)
  {
    return "dataset";
  }
  static std::string
  getParamType(const SharedClientRef<labelset::LabelSetClient>::ParamType&)
  {
    return "labelset";
  }

  template <typename U>
  static std::string getReturn(U&&)
  {
    return ReturnType<U>::getReturn();
  }

  template <size_t Offset, typename P, typename Tuple, typename All>
  static json jsonify_param(P& p, Tuple& tuple, All& allParams)
  {
    constexpr bool fixed = std::tuple_element<2, Tuple>::type::value;
    json           j;
    j["name"] = p.name;
    j["displayName"] = p.displayName;
    //    j["default"] = p.defaultValue;
    j["default"] = makeValue(p);
    j["fixed"] = fixed;
    j["type"] = getParamType(p);
    j["size"] = p.fixedSize;

    // constraints
    auto& constraintsTuple = std::get<1>(tuple);
    using constraintsTupleType = std::decay_t<decltype(constraintsTuple)>;
    constexpr size_t numConstraints =
        std::tuple_size<constraintsTupleType>::value;
    if (numConstraints > 0)
    {
      auto constraintsIndex = std::make_index_sequence<numConstraints>();
      auto c =
          constraints<Offset>(constraintsTuple, constraintsIndex, allParams);
      if (c.type() != json::value_t::null) j["constraints"] = c;
    }

    return j;
  }

  template <size_t Offset, typename Tuple, typename All>
  static json jsonify_param(const EnumT& p, Tuple&, All&)
  {
    json j;
    j["name"] = p.name;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = false;
    j["type"] = getParamType(p);
    j["size"] = 1;
    std::vector<std::string> strings(p.numOptions);
    std::copy(p.strings, p.strings + p.numOptions, strings.begin());
    j["values"] = strings;
    j["type"] = "enum";
    return j;
  }

  template <typename Tuple, size_t... Is>
  static std::array<std::string, sizeof...(Is)>
  doArgs(Tuple& args, std::index_sequence<Is...>)
  {
    return {{{getArgType(std::get<Is>(args))}...}};
  }

  template <size_t N, typename M>
  struct DoMessage
  {
    void operator()(const M& message, std::vector<json>& vec)
    {
      json messageData;
      messageData["name"] = message.name;

      typename M::ArgumentTypes args;

      messageData["args"] =
          ParameterDump::doArgs(args, typename M::IndexList{});
      auto ret = typename M::ReturnType{};
      messageData["returns"] = ParameterDump::getReturn(ret);
      vec.push_back(messageData);
    }
  };

  static  std::vector<json> jsonify_messages()
  {
    Messages          m = T::getMessageDescriptors();
    std::vector<json> ms;
    m.template iterate<DoMessage>(ms);
    return ms;
  }
};

template <class MessageResult>
struct ReturnType
{
  static std::string getReturn()
  {
    auto x = typename std::remove_reference_t<MessageResult>::type{};
    return getArgType(x);
  }
};

template <>
struct ReturnType<MessageResult<void>&>
{
  static std::string getReturn() { return "void"; }
};

} // namespace client
} // namespace fluid
